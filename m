From: Ian Kent <raven@themaw.net>
Subject: Re: [RFC] Multiple server selection and replicated mount failover
Date: Wed, 24 May 2006 13:05:28 +0800 (WST)
Message-ID: <Pine.LNX.4.64.0605241240200.3730@raven.themaw.net>
References: <Pine.LNX.4.64.0605021257500.3868@raven.themaw.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	autofs mailing list <autofs@linux.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.64.0605021257500.3868@raven.themaw.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, 2 May 2006, Ian Kent wrote:

> 
> Hi all,
> 
> For some time now I have had code in autofs that attempts to select an 
> appropriate server from a weighted list to satisfy server priority 
> selection and Replicated Server requirements. The code has been 
> problematic from the beginning and is still incorrect largely due to me 
> not merging the original patch well and also not fixing it correctly 
> afterward.
> 
> So I'd like to have this work properly and to do that I also need to 
> consider read-only NFS mount fail over.
> 
> The rules for server selection are, in order of priority (I believe):
> 
> 1) Hosts on the local subnet.
> 2) Hosts on the local network.
> 3) Hosts on other network.
> 
> Each of these proximity groups is made up of the largest number of 
> servers supporting a given NFS protocol version. For example if there were 
> 5 servers and 4 supported v3 and 2 supported v2 then the candidate group 
> would be made up of the 4 supporting v3. Within the group of candidate 
> servers the one with the best response time is selected. Selection 
> within a proximity group can be further influenced by a zero based weight 
> associated with each host. The higher the weight (a cost really) the less 
> likely a server is to be selected. I'm not clear on exactly how he weight 
> influences the selection, so perhaps someone who is familiar with this 
> could explain it?

I've re-written the server selection code now and I believe it works 
correctly.

> 
> Apart from mount time server selection read-only replicated servers need 
> to be able to fail over to another server if the current one becomes 
> unavailable. 
> 
> The questions I have are:
> 
> 1) What is the best place for each part of this process to be
>    carried out.
>    - mount time selection.
>    - read-only mount fail over.

I think mount time selection should be done in mount and I believe the 
failover needs to be done in the kernel against the list established with 
the user space selection. The list should only change when a umount 
and then a mount occurs (surely this is the only practical way to do it 
?).

The code that I now have for the selection process can potentially improve 
the code used by patches to mount for probing NFS servers and doing this 
once in one place has to be better than doing it in automount and mount.

The failover is another story.

It seems to me that there are two similar ways to do this:

1) Pass a list of address and path entries to NFS at mount time and 
intercept errors, identify if the host is down and if it is select and 
mount another server.

2) Mount each member of the list with the best one on top and intercept 
errors, identify if the host is down and if it is select another from the 
list of mounts and put it atop the mounts. Maintaining the ordering with 
this approach could be difficult.

With either of these approaches handling open files and held locks appears 
to be the the difficult part.

Anyone have anything to contribute on how I could handle this or problems 
that I will encounter?


snip ..

> 
> 3) Is there any existing work available that anyone is aware
>    of that could be used as a reference.

Still wondering about this.

> 
> 4) How does NFS v4 fit into this picture as I believe that some
>    of this functionality is included within the protocol.

And this.

NFS v4 appears quite different so should I be considering this for v2 and 
v3 only?

> 
> Any comments or suggestions or reference code would be very much 
> appreciated.

Still.

Ian

