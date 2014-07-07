Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:35593 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077AbaGGQXb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jul 2014 12:23:31 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1X4BhR-0006g1-Fx
	for linux-nfs@vger.kernel.org; Mon, 07 Jul 2014 18:23:29 +0200
Received: from bitis.umrk.nl ([82.95.126.201])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jul 2014 18:23:29 +0200
Received: from jwinius by bitis.umrk.nl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jul 2014 18:23:29 +0200
To: linux-nfs@vger.kernel.org
From: Jaap Winius <jwinius@umrk.nl>
Subject: Re: NFSv4 cross-realm support
Date: Mon, 7 Jul 2014 16:23:17 +0000 (UTC)
Message-ID: <lpehhl$o74$1@ger.gmane.org>
References: <lp1gar$eb6$1@ger.gmane.org>
	<CAHVgHyVjoVb--cfbaopoUYA4vbDCjufJVng6OM2e82q0yEMthA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 07 Jul 2014 08:36:00 -0400, Andy Adamson wrote:

> So you are supporting two Kerberos realms under one NFSv4 domain?

At some point I even hope to make it three Kerberos realms under one 
NFSv4 domain, but this also depends on a cross-realm issue with Exim4 
being resolved, so for now it's just two realms under one NFSv4 domain.

> You are using LDAP for id mapping?

Yes. After tweaking the user-olcAuthzRegexp for cn=config it seems to be 
working perfectly.

> Which version of nfs-utils and which client kernel?

I'm using Debian wheezy (stable), which comes with with nfs-common 
1.2.6-4 and kernel 3.2.0-4-amd64.

Cheers,

Jaap

