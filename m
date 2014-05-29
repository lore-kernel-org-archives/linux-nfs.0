Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:57371 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932331AbaE2Q7D convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 May 2014 12:59:03 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Chuck Lever'" <chuck.lever@oracle.com>, <linux-nfs@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>
Cc: <Anna.Schumaker@netapp.com>
References: <20140528142521.23214.39655.stgit@manet.1015granger.net>
In-Reply-To: <20140528142521.23214.39655.stgit@manet.1015granger.net>
Subject: RE: [PATCH v5 00/24] Series short description
Date: Thu, 29 May 2014 11:59:08 -0500
Message-ID: <005501cf7b5f$4e4359a0$eaca0ce0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I tested this series over cxgb4 and mlx4, running cthon04, fio read/rand-rw, and xfstests, and over mthca cthon04.  No regressions.

Tested-by: Steve Wise <swise@opengridcomputing.com>

