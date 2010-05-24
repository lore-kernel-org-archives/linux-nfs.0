Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:37201 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756888Ab0EXNww convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 09:52:52 -0400
Received: by gwaa20 with SMTP id a20so1487407gwa.19
        for <linux-nfs@vger.kernel.org>; Mon, 24 May 2010 06:52:52 -0700 (PDT)
In-Reply-To: <4BF854D4.5090500@gmail.com>
References: <4BF854D4.5090500@gmail.com>
Date: Mon, 24 May 2010 09:52:48 -0400
Message-ID: <AANLkTimUM1W5xIF3pTYDTxy4eNEC5MLcCpgTncQobAFQ@mail.gmail.com>
Subject: Re: How does the metadata-server synchronizes with data-servers ?
From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
To: redshield88888 <redshield88888@gmail.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

2010/5/22 redshield88888 <redshield88888@gmail.com>:
> Hi, all.
>
> I've succeeded to install pNFS-enabled kernel. But I wonder that how
> does pNFS behaviour.
> Especially, about synchronizations between the MetaDataServer and
> DataServers.

pNFS does not specify any MDS <-> DS protocol.

> I'd read a paper of the Calsoft's. This paper said like "There is
> heartbeats betweenthe MetaDataServer and DataServers".
> http://www.calsoftinc.com/download_pdf/White%20Papers%20-%20pnfs.pdf
>
> When will this heartbeat be started ? The instruction below is not describe
> about this, but the heartbeat will works, w'not this ?
> http://wiki.linux-nfs.org/wiki/index.php/PNFS_Setup_Instructions

These instructions need to be clarified. There are two file layout
server implementations. One is based on GFS2 where GFS2 nodes can be
an MDS, a DS or both an MDS/DS.  GFS2 has it's own heartbeat and such
between GFS2 nodes.

The other file layout implementation is spNFS, which is not a
full-blown file system in that there is limited communication between
the MDS and the DS. There is no heart beat..

Updating the pNFS setup page is on our todo list...

-->Andy
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
