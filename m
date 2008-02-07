From: "Anirban Sinha" <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>
Subject: RE: kernel exports table flushes out on running exportfs -a over mips
Date: Wed, 6 Feb 2008 23:32:30 -0800
Message-ID: <DDFD17CC94A9BD49A82147DDF7D545C5798506@exchange.ZeugmaSystems.local>
References: <DDFD17CC94A9BD49A82147DDF7D545C5743B89@exchange.ZeugmaSystems.local><20080131023654.GA45273388@ocelot.melbourne.sgi.com><DDFD17CC94A9BD49A82147DDF7D545C5743D74@exchange.ZeugmaSystems.local> <18346.38290.73331.936819@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
To: "Neil Brown" <neilb@suse.de>, <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.zeugmasystems.com ([192.139.122.66]:19496 "EHLO
	zeugmasystems.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758857AbYBGHdQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Feb 2008 02:33:16 -0500
In-Reply-To: <18346.38290.73331.936819-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry, I does look like it indeed solved the problem. Clearly, I have
missed something in my analysis of the codebase. In any case, thanks a
lot. 

Good night,

Ani


> -----Original Message-----
> From: Neil Brown [mailto:neilb@suse.de]
> Sent: Wednesday, February 06, 2008 9:22 PM
> To: Anirban Sinha
> Cc: Greg Banks; linux-nfs@vger.kernel.org
> Subject: RE: kernel exports table flushes out on running exportfs -a
> over mips
> 
> On Thursday January 31, ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org wrote:
> > >
> > > Does the MIPS box have the /proc/fs/nfsd/ filesystem mounted?
> >
> > Ahh, I see what you mean. Yes, it is mounted, both /proc/fs/nfsd and
> > /proc/fs/nfs. However, I can see from the code that
check_new_cache()
> > checks for a file "filehandle" which does not exist in that
location.
> To
> > be dead sure, I instrumented the code to insert a perror and it
> returns
> > "no such file or directory". The new_cache flag remains 0. Is this
> some
> > sort of kernel bug?
> 
> OK, that means that /proc/fs/nfs is *not* mounted.
> 
> /proc is mounted, and it contains several directories including
> /proc/fs/nfs and proc/fs/nfsd.
> 
> To get modern NFS service, you need to
>    mount -t nfsd nfsd /proc/fs/nfsd
> 
> before running any nfsd related programs (e.g. mountd, nfsd).
> Most distro do that in their startup scripts.  It seems you are
> missing this.
> 
> However it should still work.  It seems that it doesn't.
> I tried without /proc/fs/nfsd mounted and got the same result as you.
> It seems that we broke things when /var/lib/nfs/rmtab was changed to
> store IP addresses rather than host names.
> 
> The following patch to nfs-utils will fix it.   Or you can just mount
> the 'nfsd' filesystem as above.
> 
> NeilBrown
> 
> 
> 
> diff --git a/support/export/client.c b/support/export/client.c
> index 1cb242f..e96f5e0 100644
> --- a/support/export/client.c
> +++ b/support/export/client.c
> @@ -462,5 +462,5 @@ client_gettype(char *ident)
>  	sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp !=
> '.') return MCL_FQDN;
>  	sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp !=
> '\0') return MCL_FQDN;
>  	/* we lie here a bit. but technically N.N.N.N == N.N.N.N/32 :)
*/
> -	return MCL_SUBNETWORK;
> +	return MCL_FQDN;
>  }
