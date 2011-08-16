Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hub024-nj-2.exch024.serverdata.net ([206.225.165.117]:61978
	"EHLO HUB024-nj-2.exch024.serverdata.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751020Ab1HPILn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 04:11:43 -0400
Message-ID: <4E4A23E2.3020103@gluster.com>
Date: Tue, 16 Aug 2011 13:31:38 +0530
From: Shehjar Tikoo <shehjart@gluster.com>
To: <linux-nfs@vger.kernel.org>
Subject: Expected response from server not supporting v4
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi All

The following thread discusses the behaviour when the client does not 
support v4:
http://thread.gmane.org/gmane.linux.nfs/36928/

OTOH, when the server does not support v4, for eg. Gluster NFS server, 
where we support only v3, I believe v4 client will attempt to connect 
directly to port 2049 and receive connection failure errors on TCP. Does 
the current nfs client handle the situation where this results in a timeout 
for mount? We're hearing  a report of a timeout occurring on the RHEL6 
client because the server does not have v4 support. Could someone please 
shed some light on how this behaviour is handled at present? Thanks

-Shehjar
