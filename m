Return-Path: linux-nfs-owner@vger.kernel.org
Received: from static.68.134.40.188.clients.your-server.de ([188.40.134.68]:50867
	"EHLO mail02.iobjects.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752096AbaLRMbS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Dec 2014 07:31:18 -0500
Message-ID: <5492C710.20104@googlemail.com>
Date: Thu, 18 Dec 2014 13:22:40 +0100
From: =?UTF-8?B?SG9sZ2VyIEhvZmZzdMOkdHRl?=
	<holger.hoffstaette@googlemail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: 3.18.1: broken directory with one file too many
References: <pan.2014.12.16.22.19.18@googlemail.com> <20141217212159.GA11517@fieldses.org>
In-Reply-To: <20141217212159.GA11517@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/17/14 22:22, J. Bruce Fields wrote:
> On Tue, Dec 16, 2014 at 10:19:18PM +0000, Holger Hoffstätte wrote:
>> (..oddly broken directory over NFS..)
> That doesn't sound familiar.  A network trace showing the READDIR would
> be really useful.  Since this is so reproducible, I think that should be
> possible.  So do something like:
> 
> 	move the problem file into 3.14/
> 	tcpdump -s0 -wtmp.pcap -i<relevant interface>
> 	ls the directory on the client.
> 	kill tcpdump
> 	send us tmp.pcap and/or take a look at it with wireshark and see
> 	what the READDIR response looks like.

Thanks for your reply. I forgot to mention that removing other files seems to "fix" the problem, so it does not seem to be spefically the new file itself that is the cause.

I captured the "ls 3.14 | head" sequence on both the client and the server, and put the tcpudmp files here: http://hoho.duckdns.org/linux/ - let me know if that helped.

Meanwhile I'll try older/plain (unpatched) kernels. So far reverting the client to vanilla 3.18.1 or 3.14.27 has not helped..

Thanks,
Holger

