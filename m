From: Wade Hampton <wade.hampton@nsc1.net>
Subject: Re: RE: Linux client on Solaris 7 NFS server
Date: Mon, 05 Jan 2004 17:34:02 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FF9E65A.2060503@nsc1.net>
References: <200401051731.i05HVaa15457@supercomputer.org> <3FF9BEFC.6030609@nsc1.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AddIX-0003nC-1R
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 14:34:09 -0800
Received: from www.nsc1.net ([4.22.175.200] helo=mail.nsc1.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AddIW-00055x-NX
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 14:34:08 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <3FF9BEFC.6030609@nsc1.net>
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

Wade Hampton wrote:

> [snip brainfart]

This is what happens when you ask a question and then
forget you asked it....  Happy New Year....

I have not had any problems with the Solaris server
since I changed to the rsize=32768....  My system ran
for over a week without any issues.  Maybe in a week
or so (after I deliver something working), I could go back
to the earlier setting, try to crash the server, and try to
capture packets, but unless the packets are very generic
(and edited), I could not post them as they are accessing
a proprietary system.

The reason I think it is Solaris is that it crashed at least
two times a couple of days apart when I was starting my
testing, but since I changed the rsize value on 12/23,
I have not had any NFS problems.....

I'll check to see if the referenced patch has been applied
to the server.

So much for the first day back after the new year :(

Thanks,
--
Wade Hampton




-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
