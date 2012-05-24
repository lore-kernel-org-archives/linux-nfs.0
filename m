Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:59315 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161Ab2EXMlx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 May 2012 08:41:53 -0400
Received: by wibhn6 with SMTP id hn6so5850547wib.1
        for <linux-nfs@vger.kernel.org>; Thu, 24 May 2012 05:41:52 -0700 (PDT)
Message-ID: <4FBE2C8C.9090403@tonian.com>
Date: Thu, 24 May 2012 15:41:48 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Does our Kernel PNFSD-Server supports recurring layout_get with
 open_state_id
References: <4FBD7DE8.9090002@panasas.com>
In-Reply-To: <4FBD7DE8.9090002@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-05-24 03:16, Boaz Harrosh wrote:
> 
> Benny hi
> 
> If I remember/understand correctly, there is a mode in the RFC errata
> about the layout forgetful-model and a client sending a layout_get with
> an open_state_id after he already had previous state (layouts) on the file.
> 
> As I understood this is an indication to the server that client has
> "forgotten" all it's layouts on a file, and Server can assume their
> return.
> 
> Is my understanding correct?

Yes

> 
> If Yes:
> 	Did we implement the internal return of all layouts, if above
> 	open_state_id is encountered?
> 	I thought we did but I can't find this code.

True.  This is not implemented yet.

> 
> Currently, I always set ROC so there is no leak. But theoretically
> ROC does not have to be set. I'm doing some heavy lifting of
> layout_return, and I want to make sure I have not missed a spot.
> 
> If I'm correct that it is needed, and it's missing:
> My suggestion for now is that we always set ROC, disregarding FS so not to
> leak layouts and therefor inode-refs, until such time that we implement it.

According to the new errata the server will have to simulate layout returns in the ROC
case on last CLOSE if the (forgetful) client did not explicitly return the layout.
This is not implemented either :-(

Benny

> 
> Thanks
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
