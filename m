Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-2.desy.de ([131.169.56.85]:55001 "EHLO
	smtp-out-2.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254Ab0JAGMs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Oct 2010 02:12:48 -0400
Message-ID: <4CA57BC6.9030701@desy.de>
Date: Fri, 01 Oct 2010 08:12:22 +0200
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Marc Eshel <eshel@almaden.ibm.com>
CC: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org
Subject: Re: pNFS DS session
References: <4C7BDD8C.40509@panasas.com> <4CA31DC3.8070300@panasas.com> <4CA34830.1040703@desy.de> <4CA34883.40005@desy.de> <4CA34B93.2010100@panasas.com> <4CA44AAA.4030803@panasas.com> <4CA45462.1070503@desy.de> <4CA455C4.4030705@panasas.com> <OF6B8488BA.B9C50431-ON882577AF.0016FDCE-882577AF.0017999B@us.ibm.com>
In-Reply-To: <OF6B8488BA.B9C50431-ON882577AF.0016FDCE-882577AF.0017999B@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  On 10/01/2010 06:17 AM, Marc Eshel wrote:
> Hi Benny,
>
> Running connectathon I see that some times the clients decides to destroy
> the session with the DS. The test continue and the session is
> re-established. It looks like layout return reduces the hold on device
> info the reduces the hold on the client struct which decide to destroy the
> session. Is that a known problem?
>
Just wan to confirm  that we see this as well (pnfs-submit and 
pnfs-all-latest).

Tigran.
> Thanks, Marc.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

