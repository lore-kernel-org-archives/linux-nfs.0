From: bert hubert <ahu@ds9a.nl>
Subject: Re: nfs/nfsd gets stuck on a write
Date: Wed, 6 Aug 2003 13:02:16 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030806110215.GA30936@outpost.ds9a.nl>
References: <20030806104612.GB703@wiggy.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
In-Reply-To: <20030806104612.GB703@wiggy.net>
List-ID: <nfs.lists.sourceforge.net>

On Wed, Aug 06, 2003 at 12:46:13PM +0200, Wichert Akkerman wrote:
> I seem to have hit a nfs problem between two 2.6.0-test2 machines. 
> Mounting works properly, but at some point when logging in with /home
> over NFS things get stuck. A tcpdump reveals the following:

I've had problems like that go away by explicitly mounting -o tcp. 

> Both machines have a similar configuration: 2.6.0-test2 with NFS and NFS
> over TCP enabled. There are no firewalls blocking traffic between those
> two machines.

Your dump shows UDP, so give it a try.

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
