From: hanasaki <hanasaki@hanaden.com>
Subject: Re: [NFS] NFS rpc and stale handles on 2.6.x servers
Date: Thu, 29 Jan 2004 20:11:20 -0600
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <4019BD48.60905@hanaden.com>
References: <4014675D.2040405@hanaden.com>	<16409.43367.545322.356713@notabene.cse.unsw.edu.au>	<20040130012534.GE2445@srv-lnx2600.matchmail.com> <16409.46352.877421.233677@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Mike Fedyk <mfedyk@matchmail.com>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16409.46352.877421.233677@notabene.cse.unsw.edu.au>
List-ID: <nfs.lists.sourceforge.net>

Add this to your exportfs "no_subtree_check"  It seems to be a temp 
workaround.  Searching the web, the only issue with this option seems to 
be a minor performance hit (big issue for large systems).  Any chance of 
getting the patch 2.6.2?  www.kernel.org looks like its still on an RC2 
of this.


Neil Brown wrote:
> On Thursday January 29, mfedyk@matchmail.com wrote:
> 
>>On Fri, Jan 30, 2004 at 11:46:31AM +1100, Neil Brown wrote:
>>
>>>On Sunday January 25, hanasaki@hanaden.com wrote:
>>>
>>>>The below is being reported, on and off, when hitting nfs-kernel-servers
>>>>running on 2.6.0 and 2.6.1  Could someone tell me if this is smoe bug or
>>>>what?  Thanks
>>>>	RPC request reserved 0 but used 124
>>>>
>>>>Debian sarge
>>>>nfs-kernel-server
>>>>am-untils
>>>>nfsv3 over tcp
>>>>
>>>
>>>stale file handles is a known bug that is fixed in the but BK and will
>>>be in 2.6.3.
>>
>>do you mean 2.6.2?
> 
> 
> Yeh, 2.6.2 as well.. But definitely 2.6.3 :-)
> 
> 
>>I've merged the nfsd stale file handles into 2.6.1-bk2 and it is working
>>fine on a nfs server here...
> 
> 
> good, thanks.
> NeilBrown
