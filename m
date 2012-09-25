Return-Path: linux-nfs-owner@vger.kernel.org
Received: from earth.cora.nwra.com ([4.28.99.180]:36251 "EHLO
	mail.cora.nwra.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757207Ab2IYQuM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Sep 2012 12:50:12 -0400
Received: from orca.cora.nwra.com (orca.cora.nwra.com [10.10.20.2])
	(authenticated bits=0)
	by mail.cora.nwra.com (8.13.8/8.13.8) with ESMTP id q8PGiLB7016236
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 25 Sep 2012 10:44:21 -0600
Message-ID: <5061DF69.8030606@cora.nwra.com>
Date: Tue, 25 Sep 2012 10:44:25 -0600
From: Orion Poplawski <orion@cora.nwra.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Any way to allow setuid daemon to access krb5 automounted nfs directories?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Is there any way to allow setuid daemon to access krb5 automounted nfs 
directories?  Specifically I'm looking to run spamassassin's spamd on a remote 
server and access user's home directories via krb5 nfs4.  spamd changes user 
to the user receiving the email being processes and needs to modify files in 
the user's home directory.  Is there any reasonably secure way to give this 
daemon the ability to do this?  Any way to tell rpc.gssd to use a specific 
credential cache for this type of access rather than the default for that 
effective uid?

-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA, Boulder Office                  FAX: 303-415-9702
3380 Mitchell Lane                       orion@nwra.com
Boulder, CO 80301                   http://www.nwra.com
