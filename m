From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [Fwd: [PATCH 1/2] idmapd: plug memory leak in dirscancb]
Date: Tue, 2 Jan 2007 13:38:14 -0500
Message-ID: <4d569c330701021038t7894128eqc6b278a9215b2dcf@mail.gmail.com>
References: <459A9F15.9060602@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, NFSv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H1oWi-00009y-U5
	for nfs@lists.sourceforge.net; Tue, 02 Jan 2007 10:38:21 -0800
Received: from ug-out-1314.google.com ([66.249.92.173])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H1oWj-0003di-75
	for nfs@lists.sourceforge.net; Tue, 02 Jan 2007 10:38:22 -0800
Received: by ug-out-1314.google.com with SMTP id z38so4921797ugc
	for <nfs@lists.sourceforge.net>; Tue, 02 Jan 2007 10:38:19 -0800 (PST)
To: "Jeff Layton" <jlayton@redhat.com>
In-Reply-To: <459A9F15.9060602@redhat.com>
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

Hi Jeff,
Probably my fault.  I haven't sent Neil new nfs-utils patches since
mid-October.  Your patches are in my CITI series and I will be
[re-]sending them to Neil RSN.  Of course, he's welcome to import them
into his git tree any time.  I don't recall making any changes to
them.

K.C.

On 1/2/07, Jeff Layton <jlayton@redhat.com> wrote:
> Hi Neil,
>    I sent these patches out in late October, but have noticed that they have not
> yet made it into your git tree. Is there anything preventing them from going in?
>
> Thanks,
> Jeff
>
>
>
> ---------- Forwarded message ----------
> From: Jeff Layton <jlayton@redhat.com>
> To: nfs@lists.sourceforge.net
> Date: Thu, 26 Oct 2006 14:43:41 -0400
> Subject: [NFS] [PATCH 1/2] idmapd: plug memory leak in dirscancb
> There is a pretty nasty memory leak in idmapd in dirscancb(). Some of
> our customers have reported that idmapd can eat gigabytes of memory on
> machines with a large number of mounts and unmounts and a long uptime.
>
> That function uses scandir(), which malloc's an array of strings, but
> dirscancb() never frees the strings or the array. The following patch
> should correct this, but I've not yet tested it on 1.0.10 (only on the
> RHEL4 1.0.6 version). Still, the code is very similar and I'm fairly
> certain the problem exists in both versions.
>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>
> --- nfs-utils-1.0.10/utils/idmapd/idmapd.c.leak
> +++ nfs-utils-1.0.10/utils/idmapd/idmapd.c
> @@ -464,7 +464,7 @@ dirscancb(int fd, short which, void *dat
>                                 goto next;
>
>                         if ((ic = calloc(1, sizeof(*ic))) == NULL)
> -                               return;
> +                               goto out;
>                         strlcpy(ic->ic_clid, ents[i]->d_name + 4,
>                             sizeof(ic->ic_clid));
>                         path[0] = '\0';
> @@ -474,7 +474,7 @@ dirscancb(int fd, short which, void *dat
>                         if ((ic->ic_dirfd = open(path, O_RDONLY, 0)) == -1) {
>                                 idmapd_warn("dirscancb: open(%s)", path);
>                                 free(ic);
> -                               return;
> +                               goto out;
>                         }
>
>                         strlcat(path, "/idmap", sizeof(path));
> @@ -486,7 +486,7 @@ dirscancb(int fd, short which, void *dat
>                         if (nfsopen(ic) == -1) {
>                                 close(ic->ic_dirfd);
>                                 free(ic);
> -                               return;
> +                               goto out;
>                         }
>
>                         ic->ic_id = "Client";
> @@ -512,6 +512,11 @@ dirscancb(int fd, short which, void *dat
>                 } else
>                         ic->ic_scanned = 0;
>         }
> +
> +out:
> +       for (i = 0;  i < nent; i++)
> +               free(ents[i]);
> +       free(ents);
>         return;
>  }
>
>
>
>
> -------------------------------------------------------------------------
> Using Tomcat but need to do more? Need to support web services, security?
> Get stuff done quickly with pre-integrated technology to make your job easier
> Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
> http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>
>
>

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
