From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: uncaching nfs attributes
Date: Sat, 19 Jun 2004 09:24:27 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0406190914160.2434@harp.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bbhhm-0001Ud-Lb
	for nfs@lists.sourceforge.net; Sat, 19 Jun 2004 08:24:30 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1Bbhhl-0005eA-C6
	for nfs@lists.sourceforge.net; Sat, 19 Jun 2004 08:24:29 -0700
Received: from harp.ngdc.noaa.gov (harp.ngdc.noaa.gov [127.0.0.1])
	by harp.ngdc.noaa.gov (8.12.11/8.12.11) with ESMTP id i5JFORub021885
	for <nfs@lists.sourceforge.net>; Sat, 19 Jun 2004 09:24:27 -0600
Received: from localhost (ahoward@localhost)
	by harp.ngdc.noaa.gov (8.12.11/8.12.11/Submit) with ESMTP id i5JFOR4d021881
	for <nfs@lists.sourceforge.net>; Sat, 19 Jun 2004 09:24:27 -0600
To: nfs@lists.sourceforge.net
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


i am using the following algorithim to attempt to invalidate nfs caching of
file attributes:

     def uncache file
#{{{
         refresh = nil
         begin
         #
         # invalidate file
         #
           path = file.path
           dir, base = File.dirname(path), File.basename(path)
           refresh = "%s%s.%s_%s_%s_%s_%s" %
             [dir, File::SEPARATOR, base, HOSTNAME, $$, Time.now.to_i % 1024, (rand * 42000).to_i]
           File.link path, refresh
           stat = file.stat
           file.chmod stat.mode
           stat = file.stat
           File.utime stat.atime, stat.mtime, path
         #
         # invalidate dir
         #
           open(dir) do |d|
             path = d.path
             nfslock d, File::LOCK_SH|File::LOCK_NB rescue nil
             stat = d.stat
             d.chmod stat.mode rescue nil
             stat = d.stat
             File.utime stat.atime, stat.mtime, path rescue nil
           end
         rescue => e
           warn e
         ensure
           begin
             File.unlink refresh if refresh and File.exist? refresh
           rescue => e
             warn e
           end
         end
#}}}
     end

which is to say, in english:

   invalidate file:
     - link the file to an nfs safe tmpnam
     - chmod file to it's current mode
     - utime file to max(current atime, current, mtime)

   invalidate dir:
     - obtain shared fcntl based lock on directory
     - chmod dir to it's current mode
     - utime dir to max(current atime, current, mtime)

(note that this algorithim does not obtain an fcntl based lock on the file
because, in the code that uses it, one has alread been obtained for the file)

any problems with this approach?  are their other operations which are
effective at forcing the kernel to invalidate attribute caching?

kind regards,

-a
--
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| A flower falls, even though we love it; and a weed grows, even though we do
| not love it. --Dogen
===============================================================================


-------------------------------------------------------
This SF.Net email is sponsored by The 2004 JavaOne(SM) Conference
Learn from the experts at JavaOne(SM), Sun's Worldwide Java Developer
Conference, June 28 - July 1 at the Moscone Center in San Francisco, CA
REGISTER AND SAVE! http://java.sun.com/javaone/sf Priority Code NWMGYKND
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
