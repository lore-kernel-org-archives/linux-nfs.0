Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from odpn1.odpn.net ([212.40.96.53]:45367 "EHLO odpn1.odpn.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753336Ab1GDGjG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Jul 2011 02:39:06 -0400
From: "Gabor Z. Papp" <gzp@papp.hu>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs-utils 1.2.4
References: <x6tyb65wxk@gzp> <4E0E30A7.90209@RedHat.com>
Date: Mon, 04 Jul 2011 08:39:03 +0200
Message-ID: <x6zkku8s8o@gzp>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

* Steve Dickson <SteveD@redhat.com>:

| The following patch seems to take care of the problem... The 
| problem stemmed from the use of the --disable-nfsv4, which
| I will throw into my unit tests... Please let me know
| if this fixes the problem... 

| [PATCH] Make sure CONFIG_NFSIDMAP is always defined.

| CONFIG_NFSIDMAP always need to be define either
| negatively or positive whether nfsv4 is or is not
| defined.

Yes, problem fixed. Thanks.
