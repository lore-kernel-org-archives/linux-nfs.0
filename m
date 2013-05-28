Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6172 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964921Ab3E1Rxu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 May 2013 13:53:50 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r4SHroQT015538
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 28 May 2013 13:53:50 -0400
Received: from smallhat.bos.devel.redhat.com ([10.16.60.65])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id r4SHrn2x008184
	for <linux-nfs@vger.kernel.org>; Tue, 28 May 2013 13:53:49 -0400
Message-ID: <51A4EF2D.60105@RedHat.com>
Date: Tue, 28 May 2013 13:53:49 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsidmap: idmapd.conf.5 man warnings
References: <20130525021248.GA10636@master.debian.org>
In-Reply-To: <20130525021248.GA10636@master.debian.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 24/05/13 22:12, Aníbal Monsalve Salazar wrote:
> I'm using the patch in this message to build libnfsidmap in Debian.
> 
> The following command:
> 
>  MANROFFSEQ='' MANWIDTH=80 man --warnings -l -Z ./idmapd.conf.5 >/dev/null 
> 
> shows the following warnings:
> 
>  <standard input>:237: warning: macro `"' not defined
>  <standard input>:269: warning: macro `fo' not defined
>  <standard input>:278: warning: macro `".SH' not defined
> 
> and the patch below fixes them.
> 
> --- a/idmapd.conf.5	2011-12-06 07:28:10.000000000 +1100
> +++ b/idmapd.conf.5	2013-05-25 11:07:37.000000000 +1000
> @@ -31,7 +31,7 @@
>  .\"
>  .TH idmapd.conf 5 "19 Nov 2008"
>  .SH NAME
> -idmapd.conf
> +idmapd.conf \- configuration file for libnfsidmap
>  .SH SYNOPSIS
>  Configuration file for libnfsidmap.  Used by idmapd and svcgssd to map NFSv4 name to and from ids.
>  .SH DESCRIPTION
> @@ -234,7 +234,6 @@ Number of seconds before timing out an L
>  .\" -------------------------------------------------------------------
>  .\"
>  .SH EXAMPLES
> -."
>  An example
>  .I /etc/idmapd.conf
>  file:
> @@ -266,7 +265,6 @@ johndoe@OTHER.DOMAIN.ORG = johnny
>  LDAP_server = ldap.domain.org
>  LDAP_base = dc=org,dc=domain
>  
> -.fo
>  .\"
>  .\" -------------------------------------------------------------------
>  .\" Additional sections
> @@ -275,11 +273,11 @@ LDAP_base = dc=org,dc=domain
>  .SH SEE ALSO
>  .BR idmapd (8)
>  .BR svcgssd (8)
> -.".SH COMPATIBILITY
> -.".SH STANDARDS
> -.".SH ACKNOWLEDGEMENTS
> -.".SH AUTHORS
> -.".SH HISTORY
> +.\".SH COMPATIBILITY
> +.\".SH STANDARDS
> +.\".SH ACKNOWLEDGEMENTS
> +.\".SH AUTHORS
> +.\".SH HISTORY
>  .SH BUGS
>  Report bugs to <nfsv4@linux-nfs.org>
> -.".SH CAVEATS
> +.\".SH CAVEATS
Note... These have been fixed with

commit ee3099dbc71c6190cc612e923506c7d634b4b3c9
Author: Ville Skyttä <ville.skytta@iki.fi>
Date:   Tue Jun 19 10:10:40 2012 -0400

    idmapd.conf.5: Fixed some syntax typos

steved.
