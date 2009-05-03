From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: very slow NFS boot on linux-next and -mm
Date: Sun, 3 May 2009 20:40:13 +0800
Message-ID: <20090503124013.GA31700@localhost>
References: <20090503105456.GA30449@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-hotplug@vger.kernel.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20090503105456.GA30449@localhost>
Sender: linux-hotplug-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ah it's not really a NFS problem..

On Sun, May 03, 2009 at 06:54:56PM +0800, Wu Fengguang wrote:
> 
> My NFSROOT box sometimes will get stuck for a dozen seconds during boot.
> 
[snip]
> The NFSROOT client that got stuck is running latest linux-next, the
> server side is running 2.6.30-rc3.
> 
> Switching the client kernel to latest -mm makes it very reproducible.
> Here is another stack dump:
> 
> [  180.399845] udevd         D ffff8800280291e0  3056  1388      1

The udevd is doing this busy loop like mad:

        open("/etc/group", O_RDONLY|O_CLOEXEC)  = 7
        lseek(7, 0, SEEK_CUR)                   = 0
        fstat(7, {st_mode=S_IFREG|0644, st_size=797, ...}) = 0
        mmap(NULL, 797, PROT_READ, MAP_SHARED, 7, 0) = 0x7f6791601000
        lseek(7, 797, SEEK_SET)                 = 797
        munmap(0x7f6791601000, 797)             = 0
        close(7)                                = 0

udev version is 0.141-1.

Thanks,
Fengguang

