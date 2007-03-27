From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] knfsd : export : Fix bug of svc_export_parse()
Date: Tue, 27 Mar 2007 12:36:27 +0800
Message-ID: <46089F4B.7010100@cn.fujitsu.com>
References: <45FFA8E2.5000902@cn.fujitsu.com> <4608752F.1010205@cn.fujitsu.com>
	<17928.32377.572644.770583@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HW3VQ-0000Rp-9Z
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 21:42:00 -0700
Received: from [222.73.24.84] (helo=song.cn.fujitsu.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HW3VQ-0000Dh-Me
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 21:42:02 -0700
In-Reply-To: <17928.32377.572644.770583@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

  I  have test some of the export entry's type: file, dir, symlink, 
block device, char device, socket , fifo,  and dir which is a mount 
entry used your patch, this patch can resolve all of this problem.
  Thanks

Neil Brown wrote:
> On Tuesday March 27, yjwei@cn.fujitsu.com wrote:
>   
>> Nobody replied yet, but I think this is really a BUG of exportfs.
>> exportfs command does not check so strictly, so maybe some unreasonable
>> fh.key can be add to /proc/net/rpc/nfsd.fh/channel, but used this key to
>> find fh.handle, this always be fail and still retry.
>>
>> It's this correct?
>>     
>
> Sorry for not replying earlier.
>
> Yes, you have identified a real problem, but I'm not sure I agree with
> the first.
>
> If someone (mountd) tried to tell the kernel to export "/dev/null", it
> fails with an error (-ENODIR), and I think this is correct.
>
> Mountd should respond properly to this error, which it doesn't at the
> moment.
> When the request comes via the MOUNT protocol from an NFSv2 or NFSv3
> client, mountd will fail the mount as it should.
> However when the request comes from the kernel due to an NFSv4
> request, the error is just ignored.  In that case we really should be
> telling the kernel that the filehandle is not valid by writing out an
> appropriate message.
>
>
> Maybe something like this in nfs-utils.
> What do you think?
>
> Signed-off-by: Neil Brown <neilb@suse.de>
>
> ### Diffstat output
>  ./utils/mountd/cache.c |    9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
>
> diff .prev/utils/mountd/cache.c ./utils/mountd/cache.c
> --- .prev/utils/mountd/cache.c	2007-03-27 12:11:52.000000000 +1000
> +++ ./utils/mountd/cache.c	2007-03-27 12:13:40.000000000 +1000
> @@ -469,7 +469,8 @@ void nfsd_fh(FILE *f)
>  	}
>  
>  	if (found)
> -		cache_export_ent(dom, found, found_path);
> +		if (cache_export_ent(dom, found, found_path) < 0)
> +			found = 0;
>  
>  	qword_print(f, dom);
>  	qword_printint(f, fsidtype);
> @@ -619,8 +620,10 @@ void nfsd_export(FILE *f)
>  	}
>  
>  	if (found) {
> -		dump_to_cache(f, dom, path, &found->m_export);
> -		mountlist_add(dom, path);
> +		if (dump_to_cache(f, dom, path, &found->m_export) < 0)
> +			dump_to_cache(f, dom, path, NULL);
> +		else
> +			mountlist_add(dom, path);
>  	} else {
>  		dump_to_cache(f, dom, path, NULL);
>  	}
>   


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
