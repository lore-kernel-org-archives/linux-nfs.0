From: devzero@web.de
Subject: Re: stale nfs file handle with exported loopback mounts
Date: Sat, 10 Nov 2007 16:14:49 +0100
Message-ID: <2077285183@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi Neil, =


as Andreas told that the kernel fix will be in one of the next openSuSE ker=
nel updates i`m wondering if that also applies to the mountd patch.
Will there be an update package for nfs-utils or is this just too minor iss=
ue for releasing an update package ?

regards
roland


> -----Urspr=FCngliche Nachricht-----
> Von: Neil Brown <neilb@suse.de>
> Gesendet: 01.11.07 05:26:50
> An: devzero@web.de
> CC: "J. Bruce Fields" <bfields@fieldses.org>, NFS@lists.sourceforge.net
> Betreff: Re: [NFS] stale nfs file handle with exported loopback mounts


> =

> On Wednesday October 31, devzero@web.de wrote:
> > ok, i just wanted to tell that this isn`t the right way to go imho.
> > =

> > some time ago i have tested exporting a parent dir containing
> > several loopback mounted iso images with some pre-1.1.0 nfs-utils
> > version and it worked - so =EC wonder why it now seems to have issues
> > as things should have gone stable..... =

> =

> We have a way of breaking things sometimes.... It's called
> "progress". :-)
> =

> The short answer is that there is a bug in mountd which is fixed by
> this patch:
> =

> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index ce1a5a9..fd317cd 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -508,7 +508,7 @@ void nfsd_fh(FILE *f)
>  	 */
>  	qword_printint(f, 0x7fffffff);
>  	if (found)
> -		qword_print(f, found->e_path);
> +		qword_print(f, found_path);
>  	qword_eol(f);
>   out:
>  	free(found_path);
> =

> =

> The longer answer is that there is also a bug in "mount.nfs" which is
> unrelated but was slowing me down in chasing this bug, and there is
> also a bug in the NFS client which was causing my client oops and need
> a reboot every time I triggered this bug in mountd, which further
> slowed me down.
> =

> The effect of this bug in mountd is that when the NFS client calls
> GETATTR on the root of the subordinate filesystem (e.g. your
> loop-mounted isos), it got attr information about the parent. ie. the
> top-level exported filesystem (/export in your case I think).
> This has a different 'fsid' than the nfs client was expecting and
> the NFS client got confused in various ways.
> =

> Thanks for your problem report - it helped find 3 bugs!
> =

> I'll get proper patches or bug report off to the relevant maintainers
> shortly.
> =

> NeilBrown
> =



_____________________________________________________________________
Der WEB.DE SmartSurfer hilft bis zu 70% Ihrer Onlinekosten zu sparen!
http://smartsurfer.web.de/?mc=3D100071&distributionid=3D000000000066


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
