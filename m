From: "Anoop P.A." <Anoop_P.A-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org>
Subject: NFS-CIFS locking
Date: Tue, 19 May 2009 23:11:40 -0700
Message-ID: <A7DEA48C84FD0B48AAAE33F328C02014030F3FAA@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bby1mta03.pmc-sierra.com ([216.241.235.118]:52942 "EHLO
	bby1mta03.pmc-sierra.bc.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751638AbZETGLj convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 May 2009 02:11:39 -0400
Received: from bby1mta03.pmc-sierra.bc.ca (localhost.pmc-sierra.bc.ca [127.0.0.1])
	by localhost (Postfix) with SMTP id E23471070076
	for <linux-nfs@vger.kernel.org>; Tue, 19 May 2009 23:11:40 -0700 (PDT)
Received: from bby1exg02.pmc_nt.nt.pmc-sierra.bc.ca (BBY1EXG02.pmc-sierra.bc.ca [216.241.231.167])
	by bby1mta03.pmc-sierra.bc.ca (Postfix) with SMTP id D9DA61070073
	for <linux-nfs@vger.kernel.org>; Tue, 19 May 2009 23:11:40 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi List,
I have a use case where I will export one share through=A0 samba, FTP a=
nd NFS. Is there any way to achieve cross protocol locking? I am using =
Linux kernel 2.6.18.=20
Any inputs highly appreciated.

Thanks & Regards,
Anoop P A
