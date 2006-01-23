From: Steve Dickson <SteveD@redhat.com>
Subject: Re: nfs mounting problem in a linux cluster
Date: Mon, 23 Jan 2006 08:02:26 -0500
Message-ID: <43D4D3E2.5030806@RedHat.com>
References: <536c333e0601200433s270e4e47x@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F11LD-00085G-60
	for nfs@lists.sourceforge.net; Mon, 23 Jan 2006 05:02:39 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F11LB-0007Mm-Td
	for nfs@lists.sourceforge.net; Mon, 23 Jan 2006 05:02:39 -0800
To: Rajesh Kalmady <krajesh304@gmail.com>
In-Reply-To: <536c333e0601200433s270e4e47x@mail.gmail.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Rajesh Kalmady wrote:
> I have a linux cluster with RHEL 4.1 installed in all nodes and the
> NFS servers too. I have a
> strange problem of NFS mounting. When I try to mount a file system
> from the NFS server  on
> to all nodes, I find that the mount hangs in some nodes, but works in
> others normally. I go to that node, kill the mount command and run it
> again, it works. The set of nodes where it
> does not work is also random.
> 
> I was doing this using a shell script which uses rsh to issue mount
> commands on the nodes,
> one by one. I thought that maybe the NFS server cannot handle rapid
> requests, so I put a
> sleep of 2 seconds between successive mount commands. But there was no
> change in
> the behavior.
> 
> After some diagnosing using tcpdump, I found that the mount client
> first contacts the
> RPC portmapper, then the NFS port and then the port where mountd is
> listening. In those
> machines where it does not work, I found that portmapper and nfs are
> contacted but after
> this, there is no progress.
hmm... is there anything in /var/log/messages describing the failure
(on either side)?

steved.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
