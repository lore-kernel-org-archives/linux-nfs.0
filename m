From: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Subject: gssapi and nfs4
Date: Tue, 04 Nov 2008 10:43:30 -0500
Message-ID: <1225813410.2247.279.camel@brian-laptop>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server.klug.on.ca ([205.189.48.131]:2155 "EHLO
	server.klug.on.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943AbYKDPnc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Nov 2008 10:43:32 -0500
Received: from linux.interlinx.bc.ca (d193-213-184.home3.cgocable.net [67.193.213.184])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id 8A0AE2803
	for <linux-nfs@vger.kernel.org>; Tue,  4 Nov 2008 10:43:31 -0500 (EST)
Received: from [10.75.22.172] (brian-laptop.ilinx [10.75.22.172])
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 749E0800A
	for <linux-nfs@vger.kernel.org>; Tue,  4 Nov 2008 10:43:30 -0500 (EST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

So, as I stated previously, I've migrated a few of my mounts to nfs4
with gssapi to solve the limit of 16 supplemental groups issue with the
SYS security model.

I have taken notice of the gssapi export specification:

/mnt/data       gss/krb5i(<export_options>)

So with gssapi, gone is the concept of limiting exports to ip/netmasks
as well as exporting to different machines (as identified by
ip/netmasks) with different export options.  Is that correct?

How do those concepts map to gssapi then?

I realize that being a newbie to this gssapi use of nfs, this is all
probably pretty basic for most everyone here.  Is there some documents
that you could suggest for a person familiar with the SYS/nfs3 security
model to read in understanding the concepts of GSS/nfs4.  Or if you are
willing to entertain my newbie questions, let me know and I will ask
away, but I don't want to presume.

Thanx,
b.


