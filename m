Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40680 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751872Ab2GRXod (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Jul 2012 19:44:33 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1Srduz-0001TG-93
	for linux-nfs@vger.kernel.org; Wed, 18 Jul 2012 19:44:33 -0400
Date: Wed, 18 Jul 2012 19:41:52 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Liam Gretton <liam.gretton@leicester.ac.uk>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs4-acl-tools (spaces in principal names)
Message-ID: <20120718234152.GA5502@fieldses.org>
References: <50072C9E.7080707@leicester.ac.uk>
 <50072D57.4060903@leicester.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50072D57.4060903@leicester.ac.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Applied and pushed out to the git tree, thanks.

--b.

On Wed, Jul 18, 2012 at 10:40:39PM +0100, Liam Gretton wrote:
> Attached is a patch which changes the behaviour of nfs4_setfacl
> slightly to allow it to add, remove and modify ACLs which act on
> principals containing space characters.
> 
> The rationale behind this is to allow us to use nfs4_setfacl on a file
> system which is shared via CIFS to Windows clients and NFSv4. Though
> very rare in a Unix environment, Windows commonly uses user names (and
> hence principals derived from them) which contain spaces. A
> particularly common one is 'Domain Admins', the handling of which
> prompted me to look at modifying the nfs4_setfacl command.
> 
> As of 0.3.3 of nfs4-acl-tools, nfs4_setfacl fails to handle ACLs
> containing a space character no matter what attempts to quote the
> ACE or escape the space character:
> 
> # nfs4_setfacl -a "A:fdg:Domain Admins@dom.org:R" file
> Scanning ACE string 'A:fdg:Domain' failed.
> Failed while inserting ACE(s) (at index 1).
> 
> (exit status 1.)
> 
> # nfs4_setfacl -a A:fdg:Domain\ Admins@dom.org:R file
> Scanning ACE string 'A:fdg:Domain' failed.
> Failed while inserting ACE(s) (at index 1).
> 
> (exit status 1.)
> 
> The attached patch modifies the parsing of the command line and
> disallows space as an ACE delimiter. The patched version completes
> successfully:
> 
> # nfs4_setfacl -a "A:fdg:Domain Admins@dom.org:R" file
> # nfs4_getfacl file
> A:fdg:Domain Admins@le.ac.uk:rtncy
> 
> ACEs can be chained with commas, but no longer with spaces. With the
> -A, -X, -S or -e options which expect a file containing ACLs, ACEs
> can be separated with tabs, newlines and/or carriage returns as
> before.
> 
> As there's a slight change in behaviour, the patch also modifies one of
> the examples given in the EXAMPLES section of nfs4_setfacl(1) and the
> text of the 'ACL FORMAT' section of nfs4_acl.
> 
> The patches don't modify any version numbers or dates.
> 
> Regards,
> 
> Liam
> 
> -- 
> Liam Gretton                                    liam.gretton@le.ac.uk
> HPC Architect                                http://www.le.ac.uk/its/
> IT Services                                   Tel: +44 (0)116 2522254
> University Of Leicester, University Road
> Leicestershire LE1 7RH, United Kingdom
> 

> diff -rup b_nfs4-acl-tools/libnfs4acl/nfs4_insert_string_aces.c a_nfs4-acl-tools/libnfs4acl/nfs4_insert_string_aces.c
> --- b_nfs4-acl-tools/libnfs4acl/nfs4_insert_string_aces.c       2012-07-18 21:14:47.000000000 +0100
> +++ a_nfs4-acl-tools/libnfs4acl/nfs4_insert_string_aces.c       2012-07-18 11:51:43.000000000 +0100
> @@ -45,7 +45,7 @@ int nfs4_insert_string_aces(struct nfs4_
>         if ((s = sp = strdup(acl_spec)) == NULL)
>                 goto out_failed;
> 
> -       while ((ssp = strsep(&sp, " ,\t\n\r")) != NULL) {
> +       while ((ssp = strsep(&sp, ",\t\n\r")) != NULL) {
>                 if (!strlen(ssp))
>                         continue;
> 
> diff -rup b_nfs4-acl-tools/man/man1/nfs4_setfacl.1 a_nfs4-acl-tools/man/man1/nfs4_setfacl.1
> --- b_nfs4-acl-tools/man/man1/nfs4_setfacl.1    2012-07-18 21:14:47.000000000 +0100
> +++ a_nfs4-acl-tools/man/man1/nfs4_setfacl.1    2012-07-18 21:13:02.000000000 +0100
> @@ -204,7 +204,7 @@ delete the first ACE, but only print the
>  .IP - 2
>  delete the last two ACEs above:
>  .br
> -       $ nfs4_setfacl -x "A::EVERYONE@rtncy, D::EVERYONE@:waxTC" foo
> +       $ nfs4_setfacl -x A::EVERYONE@rtncy,D::EVERYONE@:waxTC foo
>  .IP - 2
>  modify (in-place) the second ACE above:
>  .br
> diff -rup b_nfs4-acl-tools/man/man5/nfs4_acl.5 a_nfs4-acl-tools/man/man5/nfs4_acl.5
> --- b_nfs4-acl-tools/man/man5/nfs4_acl.5        2012-07-18 21:14:47.000000000 +0100
> +++ a_nfs4-acl-tools/man/man5/nfs4_acl.5        2012-07-18 21:11:11.000000000 +0100
> @@ -56,7 +56,7 @@ more permissive than the ones you set.
>  .SH ACL FORMAT
>  An NFSv4 ACL is written as an
>  .IR acl_spec ,
> -which is a comma- or whitespace-delimited string consisting of one or more
> +which is a comma- or tab-delimited string consisting of one or more
>  .IR ace_specs .
>  A single NFSv4 ACE is written as an
>  .IR ace_spec ,

