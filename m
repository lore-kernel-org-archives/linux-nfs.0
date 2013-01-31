Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-da0-f44.google.com ([209.85.210.44]:44196 "EHLO
	mail-da0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754132Ab3AaFyj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jan 2013 00:54:39 -0500
Received: by mail-da0-f44.google.com with SMTP id z20so1145558dae.17
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jan 2013 21:54:39 -0800 (PST)
Message-ID: <510A06E1.8040009@gmail.com>
Date: Thu, 31 Jan 2013 11:23:37 +0530
From: "dE ." <de.techno@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: Cannot see contents of files over NFS share.
References: <5109732C.9080306@gmail.com> <20130130202017.GD14256@fieldses.org>
In-Reply-To: <20130130202017.GD14256@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yes, nfs-utils should've been compiled with nfsv41. Now it works fine.
