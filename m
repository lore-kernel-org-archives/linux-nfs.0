From: Sean Dogar <sean@catfeeder.net>
Subject: Re: nhfsstone
Date: Wed, 16 Mar 2005 09:27:56 -0700
Message-ID: <42385E8C.2060509@catfeeder.net>
References: <42374DAC.8050408@catfeeder.net> <20050316153733.GA19335@gam3.net>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="------------090207000906090302090901"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBbNQ-0007rg-OI
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 08:28:08 -0800
Received: from [165.139.44.180] (helo=strongbad.catfeeder.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DBbNP-0004oO-Ew
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 08:28:08 -0800
To: "G. Allen Morris III" <gam3-nfs@gam3.net>
In-Reply-To: <20050316153733.GA19335@gam3.net>
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

This is a multi-part message in MIME format.
--------------090207000906090302090901
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

G. Allen Morris III wrote:

>On Tue, Mar 15, 2005 at 02:03:40PM -0700, Sean Dogar wrote:
>  
>
>>Has anybody used the nfs benchmarking utility "nhfsstone"? 
>>
>>I can run it, and I can see that it's doing work (it makes test 
>>directories in the NFS-mounted directory that I start it from), but it 
>>never finishes it's testing or gives me any performance info.  I've 
>>tried the various options, including a -t 120 (I thought that this would 
>>restrict run-time to 120 seconds) and others, but I still get no output, 
>>even with verbose.  It doesn't send any output to files either.  It just 
>>runs and runs.   This is on a Redhat 8 machine as a client mounting an 
>>AIX NFS export. 
>>
>>The man page is sort of vague, but I get the impression that you can run 
>>it without any arguments, and it will do a test with the various 
>>defaults, and eventually should return. 
>>
>>Does anybody have any idea on this or do you know somewhere to point me 
>>for more info?  Most of the stuff I've found through Google has been the 
>>man page itself. 
>>
>>    
>>
>
>It seems that nhfsstone only benchmarks nfs v2 filesystems.  It is
>likely that you are using v3.
>
>Allen Morris
>  
>
That's exactly what it is...thank you.

-Sean

--------------090207000906090302090901
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
  <title></title>
</head>
<body bgcolor="#ffffff" text="#000000">
G. Allen Morris III wrote:
<blockquote cite="mid20050316153733.GA19335@gam3.net" type="cite">
  <pre wrap="">On Tue, Mar 15, 2005 at 02:03:40PM -0700, Sean Dogar wrote:
  </pre>
  <blockquote type="cite">
    <pre wrap="">Has anybody used the nfs benchmarking utility "nhfsstone"? 

I can run it, and I can see that it's doing work (it makes test 
directories in the NFS-mounted directory that I start it from), but it 
never finishes it's testing or gives me any performance info.  I've 
tried the various options, including a -t 120 (I thought that this would 
restrict run-time to 120 seconds) and others, but I still get no output, 
even with verbose.  It doesn't send any output to files either.  It just 
runs and runs.   This is on a Redhat 8 machine as a client mounting an 
AIX NFS export. 

The man page is sort of vague, but I get the impression that you can run 
it without any arguments, and it will do a test with the various 
defaults, and eventually should return. 

Does anybody have any idea on this or do you know somewhere to point me 
for more info?  Most of the stuff I've found through Google has been the 
man page itself. 

    </pre>
  </blockquote>
  <pre wrap=""><!---->
It seems that nhfsstone only benchmarks nfs v2 filesystems.  It is
likely that you are using v3.

Allen Morris
  </pre>
</blockquote>
That's exactly what it is...thank you.<br>
<br>
-Sean<br>
</body>
</html>

--------------090207000906090302090901--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
