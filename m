From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Fri, 23 Apr 2004 11:50:41 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40893B51.2080302@RedHat.com>
References: <40892507.2030004@RedHat.com> <20040423143308.GW3491@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BH2wd-0000rR-4l
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 08:50:27 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BH2wc-0008I8-KR
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 08:50:26 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040423143308.GW3491@suse.de>
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

Hi Olaf,

Olaf Kirch wrote:

>On Fri, Apr 23, 2004 at 10:15:35AM -0400, Steve Dickson wrote:
>  
>
>>Here is a 2.4 patch that will reinstantiate an inode
>>when a ESTALE error is returned on a getattr. When
>>the error occurs, a lookup is immediately issued
>>to get a new fh.
>>    
>>
>
>Brrr. Are you sure this is such a good idea?  It will have all sorts of
>bad side effects. 
>
This is why I'm asking.... In the beginning I also thought this ideas was
a bit brain dead ...  but after a bunch of trials and tribulations and not
being able to do it any other way that didn't effect normal
traffic... it kinda grew on me... :)

>For instance, you may be writing a file named "foo".
>Someone else replaces foo with their copy (mv foo-new foo) and your file
>handle becomes stale.
>  
>
True... but the write or commit will still fail with ESTALE. This
patch only effects getattrs (or stat()s). I guess my subject line
was a bit miss leading...

>If you issue a lookup immediately, you will continue writing, but
>now your writes go to the new file and produce garbage.
>  
>
Here are the tests I ran:

client: writes 100m file called foo
server: rm foo
client: the write or commit failed with ESTALE

client: writes 100m file called foo
server: renames foo to foo.old and immediately creates foo
client: failed with ESTALE

client: writes 100m file called foo
Same client: rm foo
client: finishes writing then the file is removed

client: writes 100m file called foo
Same client: renames foo to foo.old and immediately creates foo
client: both write to foo and foo.old complete and sum -r shows
        they are identical

Again only getattrs will be followed up with lookups..

>At a minimum, the lookup should occur at file open, and only if
>there are no other users of the inode.
>  
>
Unfortunately, in this particular case, there were no opens...


SteveD.


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
