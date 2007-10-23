From: Jordi Prats <jprats@cesca.es>
Subject: Re: about /proc/net/rpc/nfsd
Date: Tue, 23 Oct 2007 19:00:26 +0200
Message-ID: <471E28AA.9010501@cesca.es>
References: <471D17F8.5060709@cesca.es> <471D1DF2.4070201@oxeva.fr>
	<471E0E21.5050606@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, csmithere@gmail.com
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IkN0o-0006Jr-54
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 09:53:50 -0700
Received: from carlit.cesca.es ([84.88.0.2])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1IkN0s-0004Nv-Bv
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 09:53:55 -0700
In-Reply-To: <471E0E21.5050606@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,
What would you thing about creating a nfsd man page on section 5 with 
what does it mean every value?

I think on wiki pages should go how to interpret to enhance performance, 
but not the meaning of every value you can get on statistics.

So, I'm thinking this as two different things to answer the following 
questions:
- What is this value? (on a man page)
- How do I interpret this value to enhance performance? (on wiki's page 
about performance)

What do you think?

regards,
Jordi

Chuck Lever wrote:
> Gabriel Barazer wrote:
>> On 10/22/2007 11:36:56 PM +0200, Jordi Prats <jprats@cesca.es> wrote:
>>> Hi all,
>>> I've been researching the meaning of the contents of the 
>>> /proc/net/rpc/nfsd file using the 2.6.23 kernel sources.
>>>
>>>
>>> Sorry for this so long mail... That's all what I've got reading the 
>>> source files. There's anything incorrect? There's some "educated 
>>> guests"   So, could anyone please confirm or refute them?
>>>
>>> If you what me to do something with this I'd be glad of it!
>>
>> Wow this is an awesome job you've done here to document precisely this 
>> proc file. I've tagged your mail and copied it in a safe place.  I'm 
>> sure this would be very useful to keep a place where all these proc 
>> files are explained like this, maybe on the linux-nfs wiki ?
> 
> This belongs in the NFS server performance chapter of the NFS How-To. 
> The How-To's maintainer is csmithere@gmail.com.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
