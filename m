From: Jake Gold <jake@dtiserv2.com>
Subject: Re: NFSv4 and client caching to local disk?
Date: Tue, 1 Apr 2003 12:59:18 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030401125918.2faf68a9.jake@dtiserv2.com>
References: <20030331103850.1f40a7f9.jake@dtiserv2.com>
	<Pine.LNX.4.44.0304012046510.5929-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail01.dtiserv2.com ([216.101.214.6])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 190Ssg-00044a-00
	for <nfs@lists.sourceforge.net>; Tue, 01 Apr 2003 13:01:18 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.44.0304012046510.5929-100000@kenzo.iwr.uni-heidelberg.de>
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

Bogdan,

Thanks for the reply.

I am investigating that possibility...

We are using the Zeus Web Server to serve files off the NFS volume.
And there are some definite possibilities (using their Content Compression features)
or possibly a custom ISAPI solution we're considering...

I'm still very interested in a CacheFS-type solution, but I understand the lack of demand that
dictates its priority..


Jake

On Tue, 1 Apr 2003 21:05:36 +0200 (CEST)
Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de> wrote:
> 
> How about doing it in the application itself ? Often application has more 
> knowledge about what it needs than the OS. So in a case like the one that 
> you described I would copy the rarely modified file(s) to the local disk 
> and just before accessing them in any way check to see if they were 
> modified. If this is true read-only you don't even need to check this, but 
> otherwise you could use some rsync-style transfer to get only the parts 
> that were modified (assuming that new data is not completely different)... 
> Modification can be detected from the file attributes, md5sum or something 
> else.
> 
> The application level caching is more interesting when the cache size is 
> smaller than the data set. The OS would typically use LRU strategy to 
> make some more room in the cache when needed, but this is not always the 
> best approach - the application is the only one that can have some more 
> information about what data will be needed in the near future.
> 
> -- 
> Bogdan Costescu
> 
> IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
> Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
> Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
> E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De
> 
> 
> 
> -------------------------------------------------------
> This SF.net email is sponsored by: ValueWeb: 
> Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
> No other company gives more support or power for your dedicated server
> http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
