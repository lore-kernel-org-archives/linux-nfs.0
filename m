Return-Path: <malahal@us.ibm.com>
Date: Thu, 11 Feb 2016 12:02:49 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Benjamin Coddington <bcodding@redhat.com>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Ignore whitespace at the beginning of option tags
Message-ID: <20160211180249.GA1155@us.ibm.com>
References: <1454020727-1814-1-git-send-email-malahal@us.ibm.com>
 <56B0CA44.40105@RedHat.com>
 <alpine.OSX.2.19.9992.1602030655230.16954@planck.local>
 <20160204232956.GA1290@us.ibm.com>
 <56BA0D32.7080209@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <56BA0D32.7080209@RedHat.com>
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson [SteveD@redhat.com] wrote:
> 
> 
> On 02/04/2016 06:29 PM, Malahal Naineni wrote:
> > Sorry Steve, Ben is right. It is based on
> > "git://git.linux-nfs.org/projects/steved/libnfsidmap.git"
> > 
> > Do I need to re-clone my repo with something else?
> No... You are good... Committed!
> 
> I'm thinking we should probably roll libnfsidmap into
> nfs-utils as a .a lib... The only binary using it,
> to my knowledge, is rpc.idmapd and I don't think
> we really want anybody else using it... 
> 
> Thoughts?

libnfsidmap.so is used by nfs-ganesha project where I found the issue,
so please keep it as DSO. I don't mind folding the code into nfs-utils
project though. nfs-ganesha does need nfs-utils rpms, so nfs-ganesha
should be good as long as it is a DSO.

Regards, Malahal.
