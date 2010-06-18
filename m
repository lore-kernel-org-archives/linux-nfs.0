From: DENIEL Philippe <philippe.deniel@cea.fr>
Subject: NFSv4 and quota ?
Date: Fri, 18 Jun 2010 15:15:52 +0200
Message-ID: <4C1B7188.50607@cea.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cirse-out.extra.cea.fr ([132.166.172.106]:53643 "EHLO
	cirse-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932998Ab0FRODp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jun 2010 10:03:45 -0400
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by cirse.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.0) with ESMTP id o5IDFqKs021195
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Fri, 18 Jun 2010 15:15:52 +0200
Received: from muguet1.intra.cea.fr (muguet1.intra.cea.fr [132.166.192.6])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id o5IDFqu9016675
	for <linux-nfs@vger.kernel.org>; Fri, 18 Jun 2010 15:15:52 +0200
	(envelope-from Philippe.DENIEL-W2j0cThhBN0@public.gmane.org)
Received: from zia.bruyeres.cea.fr (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet1.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.1) with SMTP id o5IDFqH4015906
	for <linux-nfs@vger.kernel.org>; Fri, 18 Jun 2010 15:15:52 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

are quota implemented in NFSv4 ? I know the fattr4 attributes exists for 
this but are they supported by the current implementations of NFSv4.x ?

    Regards

       Philippe
