From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: RE: [PATCH] [Bug 16494] NFS client over TCP hangs due to packet
 loss
Date: Mon, 09 Aug 2010 12:55:27 -0400
Message-ID: <1281372927.8950.3.camel@heimdal.trondhjem.org>
References: <4c57cfe8.887b0e0a.2f79.4772@mx.google.com>
	 <20100803.012144.267950450.davem@davemloft.net>
	 <20100803021110.f0b3877b.akpm@linux-foundation.org>
	 <4C57EE9A.7040308@gmail.com>  <4c5ad0d6.42ecd80a.47d7.0dfc@mx.google.com>
	 <1281037822.2948.49.camel@heimdal.trondhjem.org>
	 <4c5bd64a.4a2ae30a.0283.0551@mx.google.com>
	 <4c5fc9f3.487e0e0a.2960.ffffe4ec@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "'Andrew Morton'" <akpm@linux-foundation.org>,
	"'David Miller'" <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com,
	William.Allen.Simpson@gmail.com, gilad@codefidence.com,
	ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	"'J. Bruce Fields'" <bfields@fieldses.org>,
	"'Neil Brown'" <neilb@suse.de>,
	"'Chuck Lever'" <chuck.lever@oracle.com>,
	"'Benny Halevy'" <bhalevy@panasas.com>,
	"'Alexandros Batsakis'" <batsakis@netapp.com>,
	"'Joe Perches'" <joe@perches.com>,
	Andy Chittenden <andyc@bluearc.com>
To: Andy Chittenden <andyc.bluearc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4c5fc9f3.487e0e0a.2960.ffffe4ec@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2010-08-09 at 10:27 +0100, Andy Chittenden wrote:
> A weekend run with that patch applied to 2.6.34.2 was successful. As nobody has objected, what's the next step to getting it applied to the official source trees?

Please resend me a version with a cleaned up changelog entry. I can then
push it as a bugfix.

Cheers
  Trond
