From: "xinyu wu" <xinyuwu@hotmail.com>
Subject: NAS over NFS vs SAN
Date: Wed, 11 Jun 2003 15:52:15 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <BAY1-F146cbdFkIm0OT0000f982@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from bay1-f146.bay1.hotmail.com ([65.54.245.146] helo=hotmail.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Q7td-0004wR-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Jun 2003 08:52:21 -0700
To: nfs@lists.sourceforge.net
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi,

We are planning on using some high availability storage, and the most 
popular choices are:
- NAS, but have to access it via NFS
- SAN, local disk

Many vendors have rejected NAS, because while NAS itself could have high 
availibilty, but access NFS failures could lead to data corruption.

We are going to use dual network to access NAS.

- So my question is how error prone is NFS? like Network glitches
- How good is its error recovery?
- For important data (like database), would you recommend the usage of NFS?

Thanks

Xinyu

_________________________________________________________________
Hotmail is now available on Australian mobile phones. Go to  
http://ninemsn.com.au/mobilecentral/signup.asp



-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
