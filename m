Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:58998 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754162Ab1LWCkb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Dec 2011 21:40:31 -0500
Date: Thu, 22 Dec 2011 21:40:22 -0500
From: Jim Rees <rees@umich.edu>
To: Tom Gundersen <teg@jklm.no>
Cc: linux-nfs@vger.kernel.org, Steve Dickson <steved@redhat.com>,
        Cristian =?iso-8859-1?Q?Rodr=EDguez?= <crrodriguez@opensuse.org>
Subject: Re: [PATCH] rpcbind: add support for systemd socket activation
Message-ID: <20111223024022.GA9044@umich.edu>
References: <4EEFCBF0.1070407@opensuse.org>
 <1324602327-1789-1-git-send-email-teg@jklm.no>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1324602327-1789-1-git-send-email-teg@jklm.no>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Might it be time to break up init_transport?  I see you're already using
some non-standard indentation to keep the AF_INET6 case from dropping off
the right side of the screen.
