From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: libnfsidmap
Date: Wed, 14 Nov 2007 09:59:03 -0500
Message-ID: <4d569c330711140659q2ba19b03n481c3360a9373991@mail.gmail.com>
References: <1193136846.5620.504.camel@serendib.melbourne.sgi.com>
	<1195024312.19850.130.camel@serendib.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Harshula <harshula@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IsJhj-0002Wr-Fo
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 06:59:00 -0800
Received: from rv-out-0910.google.com ([209.85.198.188])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IsJhp-0003SQ-0f
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 06:59:05 -0800
Received: by rv-out-0910.google.com with SMTP id g11so584807rvb
	for <nfs@lists.sourceforge.net>; Wed, 14 Nov 2007 06:59:03 -0800 (PST)
In-Reply-To: <1195024312.19850.130.camel@serendib.melbourne.sgi.com>
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

On Nov 14, 2007 2:11 AM, Harshula <harshula@sgi.com> wrote:
> Hi Kevin,
>
> On Tue, 2007-10-23 at 20:54 +1000, Harshula wrote:
> > Hi Bruce,
> >
> > We are building nfs-utils 1.0.7 with libnfsidmap 0.20 to avoid a bug
> > with userid mappings in libnfsidmap 0.12.
> >
> > Then we tripped over nfs/<FQDN> principals not being resolved. Luckily I
> > came across:
> > http://linux-nfs.org/pipermail/nfsv4/2006-June/004564.html
> >
> > and realised that the code to handle nfs/<FQDN> principals is now in
> > nfs-utils (utils/gssd/svcgssd_proc.c).
>
> re: utils/gssd/svcgssd_proc.c:
> -----------------------------------------------------
> /*
>  * -ENOENT means there was no mapping, any other error
>  * value means there was an error trying to do the
>  * mapping.
>  * If there was no mapping, we send down the value -1
>  * to indicate that the anonuid/anongid for the export
>  * should be used.
>  */
> if (res == -ENOENT) {
>         cred->cr_uid = -1;
>         cred->cr_gid = -1;
>         cred->cr_ngroups = 0;
>         res = 0;
>         goto out_free;
> }
> -----------------------------------------------------
>
> What happens if the server has an export with the no_root_squash option?
>
> I did a quick test with the above code snippet backported to nfs-utils
> 1.0.7 and found that an export with no_root_squash would still
> root_squash.
>
> By doing:
> -----------------------------------------------------
> /*
>  * -ENOENT means there was no mapping, any other error
>  * value means there was an error trying to do the
>  * mapping.
>  */
> if (res == -ENOENT && strncmp(sname, "nfs/", 4) == 0) {
>         cred->cr_uid = 0;
>         cred->cr_gid = 0;
>         cred->cr_ngroups = 0;
>         res = 0;
>         goto out_free;
> }
> -----------------------------------------------------
>
> The root_squash/no_root_squash behaviour was as expected. Is there any
> problem with mapping to root UID iff the name has the "nfs/" prefix?
>
> cya,
> #

1) this doesn't account for other cases where there is no mapping.
This would seem more appropriate for what you are trying to do.

if (res == -ENOENT) {
      if (strncmp(sname, "nfs/", 4) == 0) {
         cred->cr_uid = 0;
         cred->cr_gid = 0;
     } else {
         cred->cr_uid = -1;
         cred->cr_gid = -1;
     }
         cred->cr_ngroups = 0;
         res = 0;
         goto out_free;
}

2) a later version of nfs-utils allows root to use any credentials
(does not use machine credentials for all accesses by root), which
will defeat this check.

Otherwise, I think it is equivalent to the older version of nfs-utils
+ libnfsidmap.

K.C.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
