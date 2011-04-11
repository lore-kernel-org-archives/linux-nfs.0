Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47507 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755582Ab1DKVTl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Apr 2011 17:19:41 -0400
Message-ID: <4DA37068.6000905@suse.cz>
Date: Mon, 11 Apr 2011 23:19:36 +0200
From: Jiri Slaby <jslaby@suse.cz>
To: Bryan Schumaker <bjschuma@netapp.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
        mm-commits@vger.kernel.org, ML netdev <netdev@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>
Subject: Re: nfs client doesn't work [was: mmotm 2011-03-31-14-48 uploaded]
References: <201103312224.p2VMOA5g000983@imap1.linux-foundation.org> <4D96E4C5.2080302@suse.cz> <1302122693.16786.0.camel@lade.trondhjem.org> <4D9D5CC9.2040002@suse.cz> <4DA36722.2020402@suse.cz> <4DA36B19.8080200@netapp.com>
In-Reply-To: <4DA36B19.8080200@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/11/2011 10:56 PM, Bryan Schumaker wrote:
> On 04/11/2011 04:40 PM, Jiri Slaby wrote:
>> On 04/07/2011 08:42 AM, Jiri Slaby wrote:
>>> On 04/06/2011 10:44 PM, Myklebust, Trond wrote:
>>>> On Sat, 2011-04-02 at 10:56 +0200, Jiri Slaby wrote:
>>>>> On 03/31/2011 11:48 PM, akpm@linux-foundation.org wrote:
>>>>>> The mm-of-the-moment snapshot 2011-03-31-14-48 has been uploaded to
>>>>>
>>>>> Hi, nfs client is defunct in this kernel. Tcpdump says:
>>>>> 10:51:55.489717 IP 10.20.11.33.759945860 > 10.20.3.2.2049: 132 getattr
>>>>> fh 0,0/24
>>>>> 10:51:55.515927 IP 10.20.3.2.2049 > 10.20.11.33.759945860: reply ok 44
>>>>> getattr ERROR: Operation not permitted
>>>>> 10:51:55.515949 IP 10.20.11.33.921 > 10.20.3.2.2049: Flags [.], ack
>>>>> 3569361440, win 115, options [nop,nop,TS val 599750 ecr 255058541],
>>>> length 0
>>>>> 10:52:04.130310 IP 10.20.11.33.793500292 > 10.20.3.2.2049: 76 getattr fh
>>>>> 0,0/24
>>>>> 10:52:04.152178 IP 10.20.3.2.2049 > 10.20.11.33.793500292: reply ok 44
>>>>> getattr ERROR: Operation not permitted
>>>>>
>>>>> If I run the same mount command (mount -oro,intr host:dir mountpoint)
>>>>> from within a virtual machine with 2.6.38.2 there, everything mounts OK.
>>>>
>>>> Does the attached patch help?
>>>
>>> No, still the operation not permitted in the tcpdump output and no mount.
> 
> Does this patch help?
> 
> - Bryan
> 
> When attempting an initial mount, we should only attempt other
> authflavors if AUTH_UNIX receives a NFS4ERR_WRONGSEC error.
> This allows other errors to be passed back to userspace programs.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index dfd1e6d..9bf41ea 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2204,8 +2204,6 @@ static int nfs4_lookup_root_sec(struct nfs_server *server, struct nfs_fh *fhandl
>  		goto out;
>  	}
>  	ret = nfs4_lookup_root(server, fhandle, info);
> -	if (ret < 0)
> -		ret = -EAGAIN;
>  out:
>  	return ret;
>  }
> @@ -2226,7 +2224,7 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
>  
>  	for (i = 0; i < len; i++) {

No, the patch fixes a problem I have after I add the following test here:
                if (flav_array[i] > 100)
                        continue;

Without this test it still loops inside gss auth create function with:
RPC: AUTH_GSS upcall timed out.

>  		status = nfs4_lookup_root_sec(server, fhandle, info, flav_array[i]);
> -		if (status == 0)
> +		if (status != -EPERM)
>  			break;
>  	}
>  	if (status == 0)

thanks,
-- 
js
suse labs
