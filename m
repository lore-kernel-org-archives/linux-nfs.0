From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: silly names
Date: Fri, 3 Sep 2004 15:06:12 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0409031501350.8558@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.44.0409032150590.17325-100000@kenzo.iwr.uni-heidelberg.de>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C3LGF-00027t-N8
	for nfs@lists.sourceforge.net; Fri, 03 Sep 2004 14:06:19 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C3LGD-00017K-3T
	for nfs@lists.sourceforge.net; Fri, 03 Sep 2004 14:06:18 -0700
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0409032150590.17325-100000@kenzo.iwr.uni-heidelberg.de>
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

On Fri, 3 Sep 2004, Bogdan Costescu wrote:

> On Fri, 3 Sep 2004, Ara.T.Howard wrote:
>
>> are there causes other than some remote client removing an open file
>> for sillynames appearing in a directory containing a file shared
>> (via locking) by many clients?
>
> I think that renaming while a file is open also uses silly names.
>
>> i have a directory containing such a file where many sillynames
>> appear, but eventually disappear.
>
> ... after the last close().

yes, the thing is that no files are being renamed, removed, etc.  all code
that accesses the file does so in a transaction like

   aquire fcntl lock on sentinal file

     open file
     use file
     close file

   release lock

the transaction is wrapped in a

   try
   catch
   finally

type block and so is guarenteed to execute for all but kill -9.  additionally
NONE of the applications has exited for about 30 days.

also NONE of the uses removes, renames, etc. the file - only reads and writes
are done.  the semantics are single writer many reader, if this we not so the
application would crash horribly almost instantly.  i'm simply mystified as to
what's creating the sillynames - it worries me though...  my code is using the
sqlite api - so it's possible something is happening that i don't know about;
i am looking into this now.

kind regards.

-a
--
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| A flower falls, even though we love it;
| and a weed grows, even though we do not love it. 
|   --Dogen
===============================================================================


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
