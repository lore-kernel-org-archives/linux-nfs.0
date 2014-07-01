Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:3895 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752440AbaGATiY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Jul 2014 15:38:24 -0400
Date: Tue, 1 Jul 2014 15:38:18 -0400
From: mdw@linuxbox.com
To: Silas Silva <silasdb@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsd stucks in 'D' state
Message-ID: <20140701193817.GA1518@soma.private.linuxbox.com>
References: <20140701064808.GG27723@auron.ufabc.int.br>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140701064808.GG27723@auron.ufabc.int.br>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Most likely your disk is dying.  This is probably not the best
place to ask about that.  Depending on your disk type, "smartctl",
sg_info, or other tools might tell you more.  But you probably
just want to replace it anyways.  Note that flash drives tend
to 'brick' when they finally fail.

					-Marcus Watts
