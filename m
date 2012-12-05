Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.22]:57086 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750803Ab2LEJsG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Dec 2012 04:48:06 -0500
Message-ID: <50BF1854.1020204@gmx.de>
Date: Wed, 05 Dec 2012 10:48:04 +0100
From: Florian Manschwetus <florianmanschwetus@gmx.de>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: nfs4 acl problems using Nexenta-Communityedition Server and debian
 testing clients
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I setup a little network using a central storage server based on 
nexenta-Communityedition clients use homes and several shares via nfs4.
As we have some shares used for webdevelopment purposes it is desired to 
have acls inherited for specific groups access and user access 
(webserver user). I also have trouble with sticky-bit inheritance, which 
is needed as the linux gui tools unaware of nfs-acls. Are there plans to 
improve support for nfs acls?

Maybe someone here have successfully a solaris nfs server running with 
linux clients using extended acls, with inheritance working as expected?

It is really annoying having users not allowed to view/edit files/dirs 
they copied just the moment.

regards,
Florian
