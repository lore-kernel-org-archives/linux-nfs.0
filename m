From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: [ANN] lockfile-0.0.0
Date: Sun, 9 May 2004 07:03:42 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0405090702500.474-100000@fattire.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BMny8-0005xr-Vq
	for nfs@lists.sourceforge.net; Sun, 09 May 2004 06:03:48 -0700
Received: from fattire.ngdc.noaa.gov ([140.172.187.207])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BMny8-0008NV-L6
	for nfs@lists.sourceforge.net; Sun, 09 May 2004 06:03:48 -0700
Received: from localhost (ahoward@localhost)
	by fattire.ngdc.noaa.gov (8.11.6/8.11.6) with ESMTP id i49D3gD19844
	for <nfs@lists.sourceforge.net>; Sun, 9 May 2004 07:03:42 -0600
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

URLS
  
  http://raa.ruby-lang.org/list.rhtml?name=lockfile
  http://www.codeforpeople.com/lib/ruby/lockfile/


SYNOPSIS

  lib/lockfile.rb : ruby library for creating NFS safe lockfiles
  
  bin/rlock : ruby command line tool which uses this library to create
              lockfiles. run 'rlock -h' for more info


INSTALL

  sudo ruby install.rb


BASIC ALGORITHIM

  * create a globally uniq filename in the same filesystem as the desired
    lockfile - this can be nfs mounted

  * link(2) this file to the desired lockfile, ignore all errors

  * stat the uniq filename and desired lockfile to determine is they are the
    same, use only stat.rdev and stat.ino - ignore stat.nlink as NFS can cause
    this report incorrect values 

  * iff same, you have lock.  either return or run optional code block with
    optional refresher thread keeping lockfile fresh during execution of code
    block, ensuring that the lockfile is removed..

  * iff not same, sleep using incremental backoff time.  optionally remove
    lockfile if it is older than a certain time, timeout if more than a certain
    amount of time has passed attempting to lock file.


BASIC USAGE

  1)
    lockfile = Lockfile.new 'file.lock'
    begin
      lockfile.lock
      p 42
    ensure
      lockfile.unlock
    end


  2)
    require 'pstore'    # which is NOT nfs safe on it's own

    lock_opts = {         # the keys can be symbols or strings
      :retries   => 42,   # we will try 42 times to aquire the lock
      :sleep_inc => 2,    # we will sleep 2 seconds longer after each retry
      :max_sleep => 30,   # we will never sleep longer than 30 seconds however
      :max_age   => 3600, # we will blow away any files older than this
      :suspend   => 16,   # iff we steal the lock from someone else - wait this
                          # long to give them a chance to realize it
      :refresh   => 8,    # we will spawn a bg thread that touches file every 8 sec
                          # this thread also causes a StolenLockError to be
                          # thrown if the lock disappears from under us - note
                          # that the 'detection' is limited to the poll interval
      :timeout   => 300   # we simply cannot wait longer than five minutes
    }

    pstore = PStore.new 'file.db'
    lockfile = Lockfile.new 'file.db.lock', opts 
    lockfile.lock do
      pstore.transaction do
        pstore[:last_update_time] = Time.now
      end
    end


SAMPLES

  * see samples/a.rb
  * see samples/nfsstore.rb
  * see bin/rlock


enjoy.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| ADDRESS :: E/GC2 325 Broadway, Boulder, CO 80305-3328
| URL     :: http://www.ngdc.noaa.gov/stp/
| TRY     :: for l in ruby perl;do $l -e "print \"\x3a\x2d\x29\x0a\"";done 
===============================================================================





-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
