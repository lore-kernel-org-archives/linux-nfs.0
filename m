Return-Path: linux-nfs-owner@vger.kernel.org
Received: from charon.rus.uni-stuttgart.de ([129.69.1.54]:60240 "EHLO
	charon.rus.uni-stuttgart.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752794Ab2JQOuj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Oct 2012 10:50:39 -0400
Received: from localhost (localhost [127.0.0.1])
	by charon.rus.uni-stuttgart.de (Postfix) with ESMTP id 40D355FE10
	for <linux-nfs@vger.kernel.org>; Wed, 17 Oct 2012 16:50:38 +0200 (CEST)
Received: from charon.rus.uni-stuttgart.de ([127.0.0.1])
	by localhost (charon.rus.uni-stuttgart.de [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0_Jg_vbzA001 for <linux-nfs@vger.kernel.org>;
	Wed, 17 Oct 2012 16:50:37 +0200 (CEST)
Received: from tindra.iws.uni-stuttgart.de (tindra.iws.uni-stuttgart.de [129.69.98.190])
	by charon.rus.uni-stuttgart.de (Postfix) with ESMTP
	for <linux-nfs@vger.kernel.org>; Wed, 17 Oct 2012 16:50:37 +0200 (CEST)
Date: Wed, 17 Oct 2012 16:50:36 +0200
From: David Werner <david.werner@iws.uni-stuttgart.de>
To: linux-nfs@vger.kernel.org
Subject: Re: Problem with NFSv4 (server: NetApp-Filer, client
 openSUSE-11.4, 12.1 and 12.2)
Message-ID: <20121017145036.GA30550@tindra.iws.uni-stuttgart.de>
References: <20121009135919.GA16012@tindra.iws.uni-stuttgart.de>
 <20121011142034.GA4304@tindra.iws.uni-stuttgart.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20121011142034.GA4304@tindra.iws.uni-stuttgart.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, 

I now also tried the mount option 'nordirplus' which is in the shipped
with man-page listet only for NFSv3, but on this mailing list it was said is 
also available for NFSv4. At a first glance this seems also to resolve the problem too,
but seems to give better performance than the former mentioned 'lookupcache=none'.

Best regards, David 

-- 
David Werner
Universitaet Stuttgart
Institut für Wasser- und Umweltsystemmodellierung
Lehrstuhl fuer Hydromechanik &  Hydrosystemmodellierung
Pfaffenwaldring 61 ** 70569 Stuttgart
Tel.: ++49-711-685 67010 ** Fax: ++49-711-685 60430
david.werner@iws.uni-stuttgart.de
http://www.hydrosys.uni-stuttgart.de/
