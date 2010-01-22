From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/3] NFSD: Enable NFS server use of PF_INET6
Date: Fri, 22 Jan 2010 13:06:51 -0500
Message-ID: <20100122180651.GB12065@fieldses.org>
References: <20100113210650.19409.38009.stgit@localhost.localdomain> <20100113211048.19409.86029.stgit@localhost.localdomain> <20100115223519.GF30624@fieldses.org> <157AD76E-D7E1-49AC-8F1A-A4EA588EE3A9@oracle.com> <20100121225223.GR23322@fieldses.org> <817B6660-3DA4-4F19-9A7F-ABE7B5131FDE@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41332 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751371Ab0AVSF1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jan 2010 13:05:27 -0500
In-Reply-To: <817B6660-3DA4-4F19-9A7F-ABE7B5131FDE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 22, 2010 at 12:10:59PM -0500, Chuck Lever wrote:
>
> On Jan 21, 2010, at 5:52 PM, J. Bruce Fields wrote:
>
>> On Fri, Jan 15, 2010 at 06:09:17PM -0500, Chuck Lever wrote:
>>>
>>> On Jan 15, 2010, at 5:35 PM, J. Bruce Fields wrote:
>>>
>>>> On Wed, Jan 13, 2010 at 04:10:48PM -0500, Chuck Lever wrote:
>>>>> Try to use an PF_INET6 listener for NFSD if IPv6 is enabled in the
>>>>> kernel.
>>>>>
>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>> ---
>>>>>
>>>>> fs/nfsd/nfsctl.c |   36 +++++++++++++++++++++++++++++-------
>>>>> fs/nfsd/nfssvc.c |   27 ++++++++++++++++++++++-----
>>>>> 2 files changed, 51 insertions(+), 12 deletions(-)
>>>>>
>>>>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>>>>> index 2604c3e..7ebb7a5 100644
>>>>> --- a/fs/nfsd/nfsctl.c
>>>>> +++ b/fs/nfsd/nfsctl.c
>>>>> @@ -981,6 +981,26 @@ static ssize_t __write_ports_delfd(char *buf)
>>>>> 	return len;
>>>>> }
>>>>>
>>>>> +static ssize_t __write_ports_create_xprt(struct svc_serv *serv,
>>>>> +					 const char *transport,
>>>>> +					 const int family,
>>>>> +					 const unsigned short port)
>>>>> +{
>>>>> +	int err;
>>>>> +
>>>>> +	err = svc_create_xprt(serv, transport, family, port,
>>>>> +						SVC_SOCK_ANONYMOUS);
>>>>> +
>>>>> +	if (err < 0) {
>>>>> +		/* Give a reasonable perror msg for bad transport string */
>>>>> +		if (err == -ENOENT)
>>>>> +			err = -EPROTONOSUPPORT;
>>>>
>>>> I realize you're just moving this code, not writing it, so this is a
>>>> separate question, but: it looks like it's svc_create_xprt() itself
>>>> that
>>>> chooses ENOENT for this case.  Is there any reason it shouldn't just
>>>> use
>>>> EPROTONOSUPPORT from the start?
>>>
>>> I guess this little transformation is for the benefit of rpc.nfsd?  I
>>> don't know of a reason offhand why you couldn't change
>>> svc_create_xprt().  I don't immediately see any of svc_create_xprt's
>>> callers that might depend on getting ENOENT, but I didn't look very
>>> hard.
>>
>> Could I talk you into writing a patch that does that, as long as  
>> you're
>> touching this code?
>
> Since we have a little time before 2.6.34, I'll look into it.

Thanks, Chuck.

--b.
