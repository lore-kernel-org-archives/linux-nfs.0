From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Re: Move (mv) hangs with NFSv4
Date: Sun, 02 Jan 2005 19:48:54 +0100
Message-ID: <41D84216.9060504@drzeus.cx>
References: <41B0A79A.2010203@drzeus.cx> <1102097931.10878.21.camel@lade.trondhjem.org> <20041207155227.GG31250@fieldses.org> <41B61C89.2060000@drzeus.cx> <20041207211715.GQ31250@fieldses.org> <41B6E933.4090708@drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ClAmr-00016M-RJ
	for nfs@lists.sourceforge.net; Sun, 02 Jan 2005 10:49:09 -0800
Received: from a26.t1.student.liu.se
	([130.236.221.26] helo=mail.drzeus.cx ident=daemon)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1ClAml-0005Qz-I9
	for nfs@lists.sourceforge.net; Sun, 02 Jan 2005 10:49:09 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <41B6E933.4090708@drzeus.cx>
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

Pierre Ossman wrote:
> J. Bruce Fields wrote:
> 
>>
>> Thanks.  It's a problem with the idmapping on the server, argh.  Is
>> rpc.idmapd still running after this, or does it die?--b.
>>  
>>
> It's still running. The effect is only local to the mv process. Other 
> traffic to the same mount continue to work perfectly.  There has been a 
> few incidents where the entire mount hangs. But in these cases I have to 
> restart the client, not the server.
> 
> Can I get some debug output from idmapd that will pinpoint where the 
> problem is?
> 

Any updates to this issue?

Rgds
Pierre


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
