From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] blocks of zeros (NULLs) in NFS files in kernels >= 2.6.20
Date: Thu, 11 Sep 2008 13:48:49 -0400
Message-ID: <56258A29-95D5-4A8C-A097-014B8FEDFB8F@oracle.com>
References: <20080905191939.GG22796@merfinllc.com> <0A24B45A-9761-4310-B1DB-B4738964E862@oracle.com> <20080908190212.GF28123@merfinllc.com> <76bd70e30809081415h6b55a8dfl8171634c576ac946@mail.gmail.com> <20080909194644.GI5290@merfinllc.com> <8BFB4AE0-3EF1-41FA-A13B-27E380A79950@oracle.com> <20080911171908.GE12037@merfinllc.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	LKML Kernel <linux-kernel@vger.kernel.org>
To: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:42115 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752490AbYIKRuH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2008 13:50:07 -0400
In-Reply-To: <20080911171908.GE12037-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 11, 2008, at Sep 11, 2008, 1:19 PM, Aaron Straus wrote:
> Hi,
>
> On Sep 11 12:55 PM, Chuck Lever wrote:
>> A more thorough review of the NFS write and flush logic that exists  
>> in
>> 2.6.27 is needed if we choose to recognize this issue as a real
>> problem.
>
> Yep.
>
> Sorry.  I didn't mean we should revert the hunk.  I was just trying to
> help identify the cause of the new behavior.
>
> I think this is a real problem albeit not a "serious" one.  Network
> file-systems usually try to avoid readers seeing blocks of zeros in
> files, especially in this simple writer/reader case.
>
> It wouldn't be bad if the file is written out of order occasionally,  
> but
> we see this constantly now.
>
> We cannot write/read log files to NFS mounts reliably any more.  That
> seems like a valid use case which no longer works?

Were you able to modify your writer to do real fsync system calls?  If  
so, did it help?  That would be a useful data point.

NFS uses close-to-open cache coherency.  Thus we expect the file to be  
consistent and up to date after it is opened by a client, but not  
necessarily if some other client writes to it after it was opened.  We  
usually recommend file locking and direct I/O to minimize these  
problems.

Practically speaking this is often not enough for typical  
applications, so NFS client implementations go to further (non- 
standard) efforts to behave like a local file system.  This is simply  
a question of whether we can address this while not creating  
performance or correctness issues for other common use cases.

Anyway, I'm not the NFS client maintainer, so this decision is not up  
to me.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
