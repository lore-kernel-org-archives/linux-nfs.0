From: Sean Dogar <sean@catfeeder.net>
Subject: Re: Workstations connected Via NFS
Date: Tue, 31 May 2005 13:15:09 -0700
Message-ID: <429CC5CD.5050304@catfeeder.net>
References: <010E1AF633717E4BB4AC3E0BF0D77A92037A253C@nacet1mail02.effectiveteleservices.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DdD8y-0008Kl-RC
	for nfs@lists.sourceforge.net; Tue, 31 May 2005 13:15:20 -0700
Received: from [165.139.44.180] (helo=strongbad.catfeeder.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DdD8v-0002DA-RD
	for nfs@lists.sourceforge.net; Tue, 31 May 2005 13:15:20 -0700
To: Richard Shade <richard.shade@effectiveteleservices.com>
In-Reply-To: <010E1AF633717E4BB4AC3E0BF0D77A92037A253C@nacet1mail02.effectiveteleservices.local>
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

Richard Shade wrote:

>I am running Fedora Core 3 Kernel 2.6.11 NFS 4. Is there any way to see
>which machines are connected to my nfs server?  
> 
>
>  
>
Try the "showmount" command.  I believe "showmount -a" will do the trick.

-Sean


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
