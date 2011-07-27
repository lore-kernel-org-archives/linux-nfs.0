Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:34094
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754774Ab1G0VCs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 17:02:48 -0400
Date: Wed, 27 Jul 2011 17:02:44 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, yong.fan@whamcloud.com,
        adilger@whamcloud.com, tytso@mit.edu
Subject: Re: [PATCH 1/3] Return 32/64-bit dir name hash according to usage
 type
Message-ID: <20110727210244.GB9066@infradead.org>
References: <20110727110148.204979.49551.stgit@localhost.localdomain>
 <20110727110249.204979.58769.stgit@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110727110249.204979.58769.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Please don't mix fs-specific and generic changes in a single patch.

Also adding an O_ constant for a kernel-internal flag is wrong,
use the FMODE_ namespace for it.

