Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50285 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751570AbbHJNCz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Aug 2015 09:02:55 -0400
Received: from relay1.suse.de (charybdis-ext.suse.de [195.135.220.254])
	by mx2.suse.de (Postfix) with ESMTP id 4E4F4AD07
	for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2015 13:02:54 +0000 (UTC)
From: Olaf Kirch <okir@suse.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] Fix memory corruption in PMAP_CALLIT code
Date: Mon, 10 Aug 2015 15:02:52 +0200
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201508101502.53019.okir@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

