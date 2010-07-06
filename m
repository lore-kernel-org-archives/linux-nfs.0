Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:59376 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752225Ab0GFOFD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jul 2010 10:05:03 -0400
Message-ID: <4C33380A.4080904@panasas.com>
Date: Tue, 06 Jul 2010 17:04:58 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Andy Adamson <andros@netapp.com>
CC: Daniel.Muntz@emc.com, sjoshi@bluearc.com, linux-nfs@vger.kernel.org,
        bhalevy@panasas.com
Subject: Re: 4.1 client - LAYOUTCOMMIT & close
References: <A062FCC8662DA848949F7C3046B9BEAE01F3A6ED@us-email.terastack.bluearc.com> <A062FCC8662DA848949F7C3046B9BEAE01F3A6EE@us-email.terastack.bluearc.com> <6206CE0E-0A32-46A7-B648-3FCC12ED1961@netapp.com> <B9A709F368FAAF4DB4B33870F72A141DFB88F3@CORPUSMX30A.corp.emc.com> <0E2B1FE3-3B42-4BF2-BECE-A611DADF3983@netapp.com>
In-Reply-To: <0E2B1FE3-3B42-4BF2-BECE-A611DADF3983@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/06/2010 04:37 PM, Andy Adamson wrote:
> 
> On Jul 2, 2010, at 5:46 PM, <Daniel.Muntz@emc.com> wrote:
> 
> What I consider an 'extremely lame pNFS file layout server' is one  
> that requires COMMITs to the DS and then depends upon the LAYOUTCOMMIT  
> to communicate the commited data size to the MDS.
> 
(And mtime)

This is not "lame" this is "smart". There are tens of DS(s) but
thousands of clients with thousands of open files each, better
make the clients busy then the servers.

You are not looking scale.

> -->Andy
> 

Boaz
