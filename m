From: Steven Whitehouse <swhiteho@redhat.com>
Subject: Re: [PATCH 4/5] gfs2: stop giving out non-cluster-coherent leases
Date: Mon, 11 Jun 2007 10:38:18 +0100
Message-ID: <1181554698.25918.300.camel@quoit>
References: <OF0E226FEB.28B3A3C4-ON882572F5.005A6853-882572F5.005B16B6@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Robert Rappaport <robert.rappaport@gmail.com>,
	David Teigland <teigland@redhat.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Marc Eshel <eshel@almaden.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <OF0E226FEB.28B3A3C4-ON882572F5.005A6853-882572F5.005B16B6@us.ibm.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi,

On Sat, 2007-06-09 at 09:35 -0700, Marc Eshel wrote:
> This is the return code that setlease() currently returns when the lease 
> can not be obtained. Although ENOTSUPP would be more accurately describing 
> the error it will be a new return code from setlease() that is currently 
> not expected by callers to setlease(), but either return code should work.
> Marc. 
> 
I prefer EOPNOTSUPP as it more accurately describes whats going on here.
EAGAIN seems to me to imply that its something thats blocking
temporarily and that trying again at a later time might result in
success,

Steve.


