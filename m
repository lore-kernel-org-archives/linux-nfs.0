From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 10/23] NFSD: move lockd_up() before svc_addsock()
Date: Mon, 9 Mar 2009 14:19:51 -0400
Message-ID: <20090309181951.GC9408@fieldses.org>
References: <20090305212823.21342.38352.stgit@ingres.1015granger.net> <20090305213238.21342.13075.stgit@ingres.1015granger.net> <565D1A54-1E66-46B0-B57A-E7108BC12E9D@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:38610 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753804AbZCISTx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Mar 2009 14:19:53 -0400
In-Reply-To: <565D1A54-1E66-46B0-B57A-E7108BC12E9D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 09, 2009 at 02:15:11PM -0400, Chuck Lever wrote:
>
> On Mar 5, 2009, at Mar 5, 2009, 4:32 PM, Chuck Lever wrote:
>
>> Clean up.
>>
>> A couple of years ago, a series of commits, finishing with commit
>> 5680c446, swapped the order of the lockd_up() and svc_addsock() calls
>> in __write_ports().  At that time lockd_up() needed to know the
>> transport protocol of the passed-in socket to start a listener on the
>> same transport protocol.
>>
>> These days, lockd_up() doesn't take a protocol argument; it always
>> starts both a UDP and TCP listener.  It's now more straightforward to
>> try the lockd_up() first, then do a lockd_down() if the svc_addsock()
>> fails.
>>
>> Careful review of this code shows that the svc_sock_names() call is
>> used only to close the just-opened socket in case lockd_up() fails.
>> So it is no longer needed if lockd_up() is done first.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> fs/nfsd/nfsctl.c |   19 ++++++++++---------
>> 1 files changed, 10 insertions(+), 9 deletions(-)
>>
>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>> index 80f773b..aa60191 100644
>> --- a/fs/nfsd/nfsctl.c
>> +++ b/fs/nfsd/nfsctl.c
>> @@ -908,17 +908,18 @@ static ssize_t __write_ports_addfd(char *buf)
>> 	if (err != 0)
>> 		return err;
>>
>> -	err = svc_addsock(nfsd_serv, fd, buf);
>> -	if (err >= 0) {
>> -		err = lockd_up();
>> -		if (err < 0)
>> -			svc_sock_names(buf + strlen(buf) + 1, nfsd_serv, buf);
>> +	err = lockd_up();
>> +	if (err != 0)
>> +		goto out;
>>
>> -		/* Decrease the count, but don't shut down the service */
>> -		nfsd_serv->sv_nrthreads--;
>> -	}
>> +	err = svc_addsock(nfsd_serv, fd, buf);
>> +	if (err != 0)
>
> Found the "lockd: no users" BUG... this line needs to be "if (err < 0)".  
> Fix tested by Jeff Layton.

OK, good.  Will you resend that one patch at some point?  Are there any
known problems left with that series?

--b.

>
>> +		lockd_down();
>>
>> -	return err < 0 ? err : 0;
>> +out:
>> +	/* Decrease the count, but don't shut down the service */
>> +	nfsd_serv->sv_nrthreads--;
>> +	return err;
>> }
>>
>> /*
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
