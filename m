Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from jacques.telenet-ops.be ([195.130.132.50]:52291 "EHLO
	jacques.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220Ab1GEFm1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jul 2011 01:42:27 -0400
From: Luk Claes <luk@debian.org>
To: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Do not segfault because of kernel version 
Date: Tue,  5 Jul 2011 07:42:17 +0200
Message-Id: <1309844538-16008-1-git-send-email-luk@debian.org>
In-Reply-To: <20110704190003.GB12668@merit.edu>
References: <20110704190003.GB12668@merit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Resending patch taking into account the remarks of Neil Brown
and Jim Rees.

Changes to previous attempt:

* Using MAX_UINT for versions that do not start with an integer
* Using MAX_UINT when uname does not work

