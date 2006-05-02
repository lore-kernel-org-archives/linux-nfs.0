From: Ian Kent <raven@themaw.net>
Subject: [RFC] Multiple server selection and replicated mount failover
Date: Tue, 2 May 2006 13:56:47 +0800 (WST)
Message-ID: <Pine.LNX.4.64.0605021257500.3868@raven.themaw.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	autofs mailing list <autofs@linux.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: nfs@lists.sourceforge.net
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


Hi all,

For some time now I have had code in autofs that attempts to select an 
appropriate server from a weighted list to satisfy server priority 
selection and Replicated Server requirements. The code has been 
problematic from the beginning and is still incorrect largely due to me 
not merging the original patch well and also not fixing it correctly 
afterward.

So I'd like to have this work properly and to do that I also need to 
consider read-only NFS mount fail over.

The rules for server selection are, in order of priority (I believe):

1) Hosts on the local subnet.
2) Hosts on the local network.
3) Hosts on other network.

Each of these proximity groups is made up of the largest number of 
servers supporting a given NFS protocol version. For example if there were 
5 servers and 4 supported v3 and 2 supported v2 then the candidate group 
would be made up of the 4 supporting v3. Within the group of candidate 
servers the one with the best response time is selected. Selection 
within a proximity group can be further influenced by a zero based weight 
associated with each host. The higher the weight (a cost really) the less 
likely a server is to be selected. I'm not clear on exactly how he weight 
influences the selection, so perhaps someone who is familiar with this 
could explain it?

Apart from mount time server selection read-only replicated servers need 
to be able to fail over to another server if the current one becomes 
unavailable. 

The questions I have are:

1) What is the best place for each part of this process to be
   carried out.
   - mount time selection.
   - read-only mount fail over.

2) What mechanisms would be best to use for the selection process.

3) Is there any existing work available that anyone is aware
   of that could be used as a reference.

4) How does NFS v4 fit into this picture as I believe that some
   of this functionality is included within the protocol.

Any comments or suggestions or reference code would be very much 
appreciated.

Ian


