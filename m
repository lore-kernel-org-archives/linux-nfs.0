From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFS Server and long filenames
Date: Fri, 17 May 2002 15:46:49 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15588.39241.313884.154280@notabene.cse.unsw.edu.au>
References: <OF9BADB0F9.0B7422F8-ON80256BBB.00507835@diamond.philips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178aaG-0002t9-00
	for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 22:47:20 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <darren.miller@philips.com>) (for <nfs@lists.sourceforge.net>)
	By tone With Smtp ; Fri, 17 May 2002 15:47:09 +1000
To: darren.miller@philips.com
In-Reply-To: message from darren.miller@philips.com on Thursday May 16
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

On Thursday May 16, darren.miller@philips.com wrote:
> Hi all,
> 
> I need to know if there is a way of allowing excessively long filenames 
> over NFS,  we currently have
> HPUX which supports this feature.. our main problem is that some amateur 
> created a piece of software
> which is now heavily used at my site, which creates computer generated 
> files with name in excess of
> 400 characters.

At we talking 400 character of complete path name, or 400 character of
componenet name that doesn't have any '/' characters in it?

If the former, there shouldn't be any problems.
If the latter, you lose.  Many filesystems, including EXT2 and NFS
have a limit of 256 characters on component names.  
If HPUX allows longer names, then you will have to just play with the
files on HPUX.  NFS wont be abe to touch them.


> 
> I have managed to get a file in excess of 400 characters on the local 
> system disk of our Linux Slackware 
> system only I can't seem to be able to get this to work over NFS.

You did?  What filesystem were you using?

NeilBrown

> 
> baring in mind that the NFS mounting is done from Linux to HPUX.
> 
> Currently our Network Appliance NAS solution does this, and the HPs do 
> this, however Linux would appear
> to be having some difficulty.
> 
> Any ideas, help or solution to problem welcome.
> 
> Darren
> 
> ==============================================================================
> Darren Miller 
> Senior Systems Support Engineer
> Microsoft Certified Professional
> SCO Advanced Certified Engineer 
> Infomation Systems Department (Core Server Support)
> Philips Semiconductors,Milbrook Industrial Estate,Southampton,SO15 
> 0DJ,England
> <br><font size=2 face="sans-serif">Hi all,</font>
> <br>
> <br><font size=2 face="sans-serif">I need to know if there is a way of allowing excessively long filenames over NFS, &nbsp;we currently have</font>
> <br><font size=2 face="sans-serif">HPUX which supports this feature.. our main problem is that some amateur created a piece of software</font>
> <br><font size=2 face="sans-serif">which is now heavily used at my site, which creates computer generated files with name in excess of</font>
> <br><font size=2 face="sans-serif">400 characters.</font>
> <br>
> <br><font size=2 face="sans-serif">I have managed to get a file in excess of 400 characters on the local system disk of our Linux Slackware </font>
> <br><font size=2 face="sans-serif">system only I can't seem to be able to get this to work over NFS.</font>
> <br>
> <br><font size=2 face="sans-serif">baring in mind that the NFS mounting is done from Linux to HPUX.</font>
> <br>
> <br><font size=2 face="sans-serif">Currently our Network Appliance NAS solution does this, and the HPs do this, however Linux would appear</font>
> <br><font size=2 face="sans-serif">to be having some difficulty.</font>
> <br>
> <br><font size=2 face="sans-serif">Any ideas, help or solution to problem welcome.</font>
> <br>
> <br><font size=2 face="sans-serif">Darren<br>
> <br>
> ==============================================================================<br>
> Darren Miller &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<br>
> Senior Systems Support Engineer<br>
> Microsoft Certified Professional<br>
> SCO Advanced Certified Engineer &nbsp; &nbsp; &nbsp; &nbsp;<br>
> Infomation Systems Department (Core Server Support)<br>
> Philips Semiconductors,Milbrook Industrial Estate,Southampton,SO15 0DJ,England</font>

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
