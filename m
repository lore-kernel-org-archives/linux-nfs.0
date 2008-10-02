From: Jim Rees <rees@umich.edu>
Subject: Re: Is NFS v4 stable and recommend to use now?
Date: Thu, 2 Oct 2008 13:41:30 -0400
Message-ID: <20081002174129.GD6039@citi.umich.edu>
References: <beaf78240810020949j703d95cvab1c44f33bff7019@mail.gmail.com> <20081002171719.GA30408@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Roy M." <setesting001@gmail.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.mail.umich.edu ([141.211.93.160]:56631 "EHLO
	skycaptain.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753601AbYJBRle (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Oct 2008 13:41:34 -0400
In-Reply-To: <20081002171719.GA30408@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:

  Raw throughput should be the same.  And I think the little benchmarking
  I've seen has found that to be true.

Actually v4 is better on fast nets because you can make the iosize bigger.
