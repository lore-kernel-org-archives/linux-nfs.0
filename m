Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:51320 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932352Ab0HCQnU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Aug 2010 12:43:20 -0400
Received: from localhost (localhost [127.0.0.1])
	by magus.merit.edu (Postfix) with ESMTP id 5907522566D
	for <linux-nfs@vger.kernel.org>; Tue,  3 Aug 2010 12:43:19 -0400 (EDT)
Received: from magus.merit.edu ([127.0.0.1])
	by localhost (magus.merit.edu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id WC4Carn7h5fQ for <linux-nfs@vger.kernel.org>;
	Tue,  3 Aug 2010 12:43:19 -0400 (EDT)
Received: from merit.edu (unknown [198.108.18.100])
	by magus.merit.edu (Postfix) with ESMTPSA id 2584722566B
	for <linux-nfs@vger.kernel.org>; Tue,  3 Aug 2010 12:43:19 -0400 (EDT)
Date: Tue, 3 Aug 2010 12:43:18 -0400
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Subject: Re: numeric UIDs
Message-ID: <20100803164318.GB13896@merit.edu>
References: <201008030401.33552.dreck@vmsd.ath.cx>
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <201008030401.33552.dreck@vmsd.ath.cx>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Victor Mataré wrote:

  I'd like to try and 
  make a case for implementing an option to turn off UID mapping completely (or 
  at least for unknown UIDs).

I've always thought this would be useful too, just as an option for auth_sys
of course.  Some people think it's a security problem but since there is no
security in an auth_sys mount I don't see what the issue is.
