From: Gcc k6 testing account <caligula@cam029208.student.utwente.nl>
Subject: Re: 2.5.32 bootfailure for nfsroot
Date: Mon, 2 Sep 2002 10:44:42 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <43918.353439267$1030956640@news.gmane.org>
References: <Pine.LNX.4.44.0208281746170.21556-100000@cam029208.student.utwente.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from netlx010.civ.utwente.nl ([130.89.1.92])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17lmqm-0002KK-00
	for <nfs@lists.sourceforge.net>; Mon, 02 Sep 2002 01:46:24 -0700
To: linux-kernel@vger.kernel.org
In-Reply-To: <Pine.LNX.4.44.0208281746170.21556-100000@cam029208.student.utwente.nl>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Wed, 28 Aug 2002, Gcc k6 testing account wrote:

> 
> Ave people
> 
> The subject says it all. 
> 2.5.32 doesn't boot when using nfsroot.
> same systems running fine with 2.4.19/2.5.31
> 
> 
> SYSTEMS:
>    athlon with/without preempt. (flatbak)
>    i586 with preempt.           (cam029205)
> 
> The relevant configs/dmesg/lspci are on 
> cam029208.student.utwente.nl/~caligula. 
> 
> 
> SYMPTOMS:
> I'm using loadlin to load the kernels. I see the kernel loading,unzipping 
> and then...black screen followed by reboot.
> 
> 
> Greetz Mu
> 
> 
> 

Small update.
Still no joy with 2.5.33. Same results,same symptoms :(

Greetz Mu











-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
