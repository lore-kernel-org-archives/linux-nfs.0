From: "Kirill A. Shutemov" <kas@openvz.org>
Subject: Re: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
Date: Fri, 7 Jan 2011 13:12:22 +0200
Message-ID: <20110107111222.GA19395@shutemov.name>
References: <1293628470-28386-1-git-send-email-kas@openvz.org>
 <20110105114155.GN19804@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirill A. Shutemov" <kas@openvz.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	Pavel Emelyanov <xemul@parallels.com>,
	linux-nfs@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110105114155.GN19804@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 05, 2011 at 11:41:55AM +0000, Al Viro wrote:
> On Wed, Dec 29, 2010 at 03:14:18PM +0200, Kirill A. Shutemov wrote:
> > Prepare nfs/sunrpc stack to use multiple instances of rpc_pipefs.
> 
> Won't that make sunrpc impossible to rmmod once you've got it in?
> Note that having a reference to vfsmount pins it down, which pins
> the superblock down, which pins the file_system_type down, which
> pins the damn module down.  So cleanup_sunrpc() won't be ever called,
> AFAICS...

Hm.. rpc_pipe_fs_type.owner = NULL seems fix the problem.
Is it valid solution in this case?

-- 
 Kirill A. Shutemov
