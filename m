From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: nhfsstone
Date: Wed, 16 Mar 2005 10:19:45 +0200
Message-ID: <200503161019.45094.vda@ilport.com.ua>
References: <42374DAC.8050408@catfeeder.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBTll-0006Wn-1c
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 00:20:45 -0800
Received: from [195.66.192.168] (helo=port.imtp.ilyichevsk.odessa.ua)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1DBTle-0005sS-0L
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 00:20:44 -0800
To: Sean Dogar <sean@catfeeder.net>, nfs@lists.sourceforge.net
In-Reply-To: <42374DAC.8050408@catfeeder.net>
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

On Tuesday 15 March 2005 23:03, Sean Dogar wrote:
> Has anybody used the nfs benchmarking utility "nhfsstone"? 
> 
> I can run it, and I can see that it's doing work (it makes test 
> directories in the NFS-mounted directory that I start it from), but it 
> never finishes it's testing or gives me any performance info.  I've 
> tried the various options, including a -t 120 (I thought that this would 
> restrict run-time to 120 seconds) and others, but I still get no output, 
> even with verbose.  It doesn't send any output to files either.  It just 
> runs and runs.   This is on a Redhat 8 machine as a client mounting an 
> AIX NFS export. 
> 
> The man page is sort of vague, but I get the impression that you can run 
> it without any arguments, and it will do a test with the various 
> defaults, and eventually should return. 
> 
> Does anybody have any idea on this or do you know somewhere to point me 
> for more info?  Most of the stuff I've found through Google has been the 
> man page itself. 

I'd look into its source code (only 36k of it) if I were you.
--
vda



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
