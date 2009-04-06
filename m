From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: next-20090406: nfsd build fails
Date: Mon, 6 Apr 2009 11:27:08 +0400
Message-ID: <a4423d670904060027y44550d99g2cb40ce415dbb048@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	linux-nfs@vger.kernel.org, andros@netapp.com, bhalevy@panasas.com,
	bfields@citi.umich.edu
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

fs/nfsd/nfssvc.c: In function 'set_max_drc':
fs/nfsd/nfssvc.c:240: error: 'NFSD_DRC_SIZE_SHIFT' undeclared

CONFIG_NFSD_V4 is not set
